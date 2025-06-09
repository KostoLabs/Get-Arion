class CreateInventoryValuations < ActiveRecord::Migration[7.2]
  def change
    create_table :inventory_valuations, id: :uuid do |t|
      t.references :inventory, null: false, foreign_key: true, type: :uuid
      t.references :import, null: false, foreign_key: true, type: :uuid
      t.decimal :value
      t.date :date

      t.timestamps
    end
  end
end
