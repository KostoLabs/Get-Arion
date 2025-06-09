class CreateFinancialLiabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :financial_liabilities, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :lending_type, null: false                      # overdraft, obligation, ...
      t.string :lending_rate_type, null: false                 # fixed, variable
      t.decimal :lending_rate, precision: 10, scale: 3
      t.date :lending_start, null: false
      t.date :lending_close                                     # nil if overdraft
      t.string :lenders
      t.string :collateral                                      # real_estate, inventory, ...
      t.decimal :haircut, precision: 10, scale: 3               # ex: 0.20 pour 20 %
      t.decimal :collateral_floor, precision: 19, scale: 4      # = lending_amount * haircut, ou nil

      t.timestamps
    end
  end
end
