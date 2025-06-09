class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :storage, null: false
      t.string :inventory_type, null: false
      t.string :address
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country

      t.timestamps
    end
  end
end
