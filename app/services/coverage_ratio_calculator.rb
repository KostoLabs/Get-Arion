class CoverageRatioCalculator
  def initialize(family:, date:)
    @family = family
    @date = date
  end

  def call
    # Récupère les dernières valorisations (une par stock)
    inventory_value = Account::Entry
      .account_valuations
      .joins(:account)
      .where(accounts: { accountable_type: "Inventory", family_id: @family.id })
      .where("account_entries.date <= ?", @date)
      .select("DISTINCT ON (account_id) account_entries.account_id, account_entries.amount, account_entries.date")
      .order("account_id, date DESC")
      .sum(&:amount)

    liabilities_value = Account
      .where(accountable_type: "FinancialLiability", family_id: @family.id)
      .sum(:balance)

    Rails.logger.debug "📊 [Coverage] Inventory = #{inventory_value}, Liabilities = #{liabilities_value}"

    return nil if liabilities_value.zero?

    inventory_value / liabilities_value * 100
  end
end
