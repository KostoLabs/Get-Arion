class Depository < ApplicationRecord
  include Accountable

  SUBTYPES = [
    [ "Compte courant", "checking" ],
    [ "Compte épargne", "savings" ]
  ].freeze

  class << self
    def display_name
      "Cash"
    end

    def color
      "#875BF7"
    end

    def classification
      "asset"
    end

    def icon
      "landmark"
    end
  end
end
