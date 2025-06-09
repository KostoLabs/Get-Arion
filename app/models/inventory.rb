class Inventory < ApplicationRecord
  include Accountable

  STORAGES = %w[depository warehouse store other].freeze
  INVENTORY_TYPES = ["raw material", "finished products", "both"].freeze

  validates :storage, presence: true, inclusion: { in: STORAGES }
  validates :inventory_type, presence: true, inclusion: { in: INVENTORY_TYPES }
  validates :asset_customer_place, presence: true

  delegate :family, to: :account
  before_validation :generate_asset_customer_place, on: :create

  class << self
    def display_name
      "Stock"
    end

    def color
      "#1D9BF0"
    end

    def classification
      "asset"
    end

    def icon
      "package"
    end
  end

  private

    def generate_asset_customer_place
      self.asset_customer_place ||= "LIEU-#{SecureRandom.hex(4).upcase}"
    end
end
