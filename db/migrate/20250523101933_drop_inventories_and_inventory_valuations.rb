class DropInventoriesAndInventoryValuations < ActiveRecord::Migration[7.0]
  def change
    drop_table :inventory_valuations do |t|
      t.uuid :inventory_id, null: false
      t.uuid :import_id, null: false
      t.decimal :value
      t.date :date
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :name
    end

    drop_table :inventories do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :year_built
      t.integer :area_value
      t.string :area_unit
      t.string :inventory_kind
      t.string :storage_type
      t.uuid :family_id, null: false
      t.string :name
      t.string :customer_id
      t.decimal :balance, precision: 15, scale: 2
      t.decimal :unit_price, precision: 15, scale: 2
      t.decimal :total_value, precision: 15, scale: 2
      t.string :currency
      t.string :unit
      t.uuid :import_id
      t.jsonb :metadata, default: {}
    end
  end
end
