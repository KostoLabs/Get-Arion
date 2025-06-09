class Investment < ApplicationRecord
  include Accountable

  SUBTYPES = [
    [ "Courtage", "brokerage" ],
    [ "Pension", "pension" ],
    [ "Retraite", "retirement" ],
    [ "401(k)", "401k" ],
    [ "401(k) traditionnel", "traditional_401k" ],
    [ "401(k) Roth", "roth_401k" ],
    [ "Plan 529", "529_plan" ],
    [ "Compte épargne santé", "hsa" ],
    [ "Fonds commun", "mutual_fund" ],
    [ "IRA traditionnel", "traditional_ira" ],
    [ "IRA Roth", "roth_ira" ],
    [ "Investisseur providentiel", "angel" ]
  ].freeze

  class << self
    def color
      "#1570EF"
    end

    def classification
      "asset"
    end

    def icon
      "line-chart"
    end
  end
end
