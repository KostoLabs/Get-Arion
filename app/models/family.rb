class Family < ApplicationRecord
  include Synthable, Plaidable, Syncable, AutoTransferMatchable

  before_create :set_default_timezone
  before_create :set_default_locale_and_country

  DATE_FORMATS = [
    [ "JJ/MM/AAAA", "%d/%m/%Y" ],
    [ "MM-DD-YYYY", "%m-%d-%Y" ],
    [ "DD.MM.YYYY", "%d.%m.%Y" ],
    [ "DD-MM-YYYY", "%d-%m-%Y" ],
    [ "YYYY-MM-DD", "%Y-%m-%d" ],
    [ "YYYY/MM/DD", "%Y/%m/%d" ],
    [ "MM/DD/YYYY", "%m/%d/%Y" ],
    [ "D/MM/YYYY", "%e/%m/%Y" ],
    [ "YYYY.MM.DD", "%Y.%m.%d" ]
  ].freeze

  has_many :users, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :inventories, through: :accounts, source: :accountable, source_type: 'Inventory'
  has_many :plaid_items, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :imports, dependent: :destroy
  has_many :issues, through: :accounts
  has_many :entries, through: :accounts
  has_many :transactions, through: :accounts
  has_many :trades, through: :accounts
  has_many :holdings, through: :accounts
  has_many :tags, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :merchants, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :budget_categories, through: :budgets
  has_one :corporate

  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }
  validates :date_format, inclusion: { in: DATE_FORMATS.map(&:last) }
  validates :currency, inclusion: { in: ["EUR", "USD"] }

  def balance_sheet
    @balance_sheet ||= BalanceSheet.new(self)
  end

  def income_statement
    @income_statement ||= IncomeStatement.new(self)
  end

  def sync_data(start_date: nil)
    update!(last_synced_at: Time.current)

    accounts.manual.each do |account|
      account.sync_later(start_date: start_date)
    end

    plaid_items.each do |plaid_item|
      plaid_item.sync_later(start_date: start_date)
    end
  end

  def post_sync
    broadcast_refresh
  end

  def syncing?
    Sync.where(
      "(syncable_type = 'Family' AND syncable_id = ?) OR
       (syncable_type = 'Account' AND syncable_id IN (SELECT id FROM accounts WHERE family_id = ? AND plaid_account_id IS NULL)) OR
       (syncable_type = 'PlaidItem' AND syncable_id IN (SELECT id FROM plaid_items WHERE family_id = ?))",
      id, id, id
    ).where(status: [ "pending", "syncing" ]).exists?
  end

  def eu?
    country != "US" && country != "CA"
  end

  def get_link_token(webhooks_url:, redirect_url:, accountable_type: nil, region: :us, access_token: nil)
    provider = if region.to_sym == :eu
      self.class.plaid_eu_provider
    else
      self.class.plaid_us_provider
    end

    return nil unless provider

    provider.get_link_token(
      user_id: id,
      webhooks_url: webhooks_url,
      redirect_url: redirect_url,
      accountable_type: accountable_type,
      access_token: access_token
    ).link_token
  end

  # ABONNEMENTS

  def subscribed?
    subscribed_to_base? || subscribed_to_premium?
  end

  def subscribed_to_base?
    stripe_subscription_status == "active" && stripe_plan_id == ENV["STRIPE_PLAN_BASE_ID"]
  end

  def subscribed_to_premium?
    stripe_premium_subscription_status == "active" && stripe_premium_plan_id == ENV["STRIPE_PLAN_PREMIUM_ID"]
  end

  # Nombre max de comptes autorisés selon l'abonnement
  def max_accounts_allowed
    if subscribed_to_premium?
      { asset: 3, liability: 3 }
    elsif subscribed_to_base?
      { asset: 1, liability: 1 }
    else
      { asset: 0, liability: 0 }
    end
  end

  def active_accounts_count
    @active_accounts_count ||= active_accounts_breakdown.values.sum
  end

  def active_accounts_breakdown
    @active_accounts_breakdown ||= accounts.active
      .group(:classification)
      .count
      .transform_keys(&:to_sym)
      .reverse_merge(asset: 0, liability: 0)
  end

  # Peut ajouter un nouveau compte si pas au max
  def can_add_account?(classification = nil)
    if classification.nil?
      max_allowed = max_accounts_allowed
      current_breakdown = active_accounts_breakdown
      (current_breakdown[:asset] < max_allowed[:asset]) || 
      (current_breakdown[:liability] < max_allowed[:liability])
    else
      max = max_accounts_allowed[classification.to_sym]
      current = active_accounts_breakdown[classification.to_sym]
      current < max
    end
  end

  def account_limit_message(_classification = nil)
    if !subscribed?
      "Vous devez vous abonner à Arion+ pour ajouter un compte."
    elsif subscribed_to_base?
      "Vous devez passer à Arion+ Premium pour ajouter d'autres comptes."
    elsif subscribed_to_premium?
      "Vous avez atteint la limite de 3 comptes avec votre abonnement Arion+ Premium."
    else
      "Vous ne pouvez pas ajouter de compte."
    end
  end

  def can_import?
    subscribed?
  end

  def primary_user
    users.order(:created_at).first
  end

  def oldest_entry_date
    entries.order(:date).first&.date || Date.current
  end

  # def active_accounts_count
  #   accounts.active.count
  # end

  def requires_data_provider?
    @requires_data_provider ||= begin
      stats = Rails.cache.fetch(build_cache_key("data_provider_check"), expires_in: 1.hour) do
        { has_trades: trades.exists?,
          has_non_family_currency_accounts: accounts.where.not(currency: self.currency).exists?,
          entry_currencies: entries.distinct.pluck(:currency) }
      end
      return true if stats[:has_trades]
      return true if stats[:has_non_family_currency_accounts]
      currencies = stats[:entry_currencies]
      return true if currencies.count > 1
      return true if currencies.count > 0 && currencies.first != self.currency
      false
    end
  end

  def build_cache_key(key)
    [
      "family",
      id,
      key,
      entries_cache_timestamp
    ].compact.join("_")
  end

  def entries_cache_timestamp
    @entries_cache_timestamp ||= entries.maximum(:updated_at)
  end

  def clear_entries_cache_timestamp!
    @entries_cache_timestamp = nil
  end

  private

    def clear_account_cache
      @active_accounts_breakdown = nil
      @active_accounts_count = nil
      @requires_data_provider = nil
    end

    def set_default_currency
      self.currency ||= "EUR"
    end

    def set_default_timezone
      self.timezone ||= "Europe/Paris"
    end

    def set_default_locale_and_country
      self.locale ||= "fr"
      self.country ||= "FR"
    end
end
