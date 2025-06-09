class RecreateInventoriesAndInventoryValuations < ActiveRecord::Migration[7.0]
  def up
    # Crée la table inventories minimale
    create_table :inventories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :family_id, null: false
      t.string :name
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:family_id], name: "index_inventories_on_family_id"
    end

    # Crée la table inventory_valuations minimale
    create_table :inventory_valuations, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :inventory_id, null: false
      t.date :date
      t.decimal :value
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.index [:inventory_id], name: "index_inventory_valuations_on_inventory_id"
    end
  end

  def down
    drop_table :inventory_valuations
    drop_table :inventories
  end
end
