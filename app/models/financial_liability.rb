# app/models/financial_liability.rb
class FinancialLiability < ApplicationRecord
  include Accountable

  COLLATERAL_REQUIRED = %w[real_estate inventory stocks materials invoices]

  after_create :set_collateral_floor
  before_update :set_collateral_floor

  # validates :lending_type, :lending_rate_type, :lending_start, presence: true

  def self.classification
    "liability"
  end

  def self.icon
    "hand-coins"
  end

  def self.color
    "#8B5CF6"
  end

  private

    def set_collateral_floor
  puts "🔍 === set_collateral_floor called! ==="
  puts "🔍 collateral: '#{collateral}'"
  puts "🔍 haircut: #{haircut} (present?: #{haircut.present?})"
  puts "🔍 account: #{account.present?} (balance: #{account&.balance})"
  puts "🔍 COLLATERAL_REQUIRED: #{COLLATERAL_REQUIRED}"
  puts "🔍 collateral included?: #{COLLATERAL_REQUIRED.include?(collateral)}"

  if COLLATERAL_REQUIRED.include?(collateral) && haircut.present?
    calculated = account&.balance.to_d * (haircut.to_d / 100)
    puts "🔍 ✅ Calculating: #{account&.balance} × (#{haircut} / 100) = #{calculated}"
    self.collateral_floor = calculated
  else
    puts "🔍 ❌ Conditions not met, setting to nil"
    self.collateral_floor = nil
  end

  puts "🔍 Final collateral_floor: #{collateral_floor}"
  puts "🔍 === end set_collateral_floor ==="
end
end
