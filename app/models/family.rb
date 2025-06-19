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

  # ──────────────── ABONNEMENTS ────────────────

  def subscribed?
    subscribed_to_base? || subscribed_to_premium? || subscribed_to_enterprise?
  end

  def subscribed_to_base?
    stripe_subscription_status == "active" && stripe_plan_id == ENV["STRIPE_PLAN_BASE_ID"]
  end

  def subscribed_to_premium?
    stripe_premium_subscription_status == "active" && stripe_premium_plan_id == ENV["STRIPE_PLAN_PREMIUM_ID"]
  end

  def subscribed_to_enterprise?
    stripe_company_subscription_status == "active" && stripe_company_plan_id == ENV["STRIPE_PLAN_COMPANY_ID"]
  end

  def max_accounts_allowed
    if subscribed_to_enterprise?
      { inventory: nil, financial_liability: nil, depository: nil }
    elsif subscribed_to_premium?
      { inventory: 3, financial_liability: 3, depository: nil }
    elsif subscribed_to_base?
      { inventory: 1, financial_liability: 1, depository: 2 }
    else
      { inventory: 0, financial_liability: 0, depository: 0 }
    end
  end

  def active_accounts_count
    @active_accounts_count ||= accounts.active.count
  end

  def active_accounts_breakdown_by_type
    accounts.active.group(:accountable_type).count
  end

  def can_add_account?(type = nil)
    limits = max_accounts_allowed
    return true if subscribed_to_enterprise?

    if type.nil?
      limits.any? do |type_key, limit|
        limit.nil? || (active_accounts_breakdown_by_type[type_key.to_s.camelize] || 0) < limit
      end
    else
      key = type.to_s.camelize
      limit = limits[type.to_sym]
      current = active_accounts_breakdown_by_type[key] || 0
      limit.nil? || current < limit
    end
  end

  def account_limit_message(type = nil)
    return "Vous devez être abonné pour ajouter un compte." unless subscribed?

    if subscribed_to_base?
      case type.to_s
      when "inventory" then "L’abonnement Arion One permet un seul compte stock."
      when "financial_liability" then "L’abonnement Arion One permet une seule dette personnalisée."
      when "depository" then "L’abonnement Arion One permet deux comptes bancaires."
      else "L’abonnement Arion One est limité à certains comptes."
      end
    elsif subscribed_to_premium?
      "Vous avez atteint la limite de votre abonnement Arion One+."
    else
      "Abonnement Arion Enterprise actif : pas de limite."
    end
  end

  def can_downgrade_to?(target_plan)
    limits = case target_plan
            when :base
              { inventory: 1, financial_liability: 1, depository: 2 }
            when :premium
              { inventory: 3, financial_liability: 3, depository: nil }
            else # :enterprise
              { inventory: nil, financial_liability: nil, depository: nil }
            end

    breakdown = active_accounts_breakdown_by_type.transform_keys(&:underscore).symbolize_keys

    limits.all? do |type, limit|
      limit.nil? || (breakdown[type] || 0) <= limit
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
    [ "family", id, key, entries_cache_timestamp ].compact.join("_")
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
