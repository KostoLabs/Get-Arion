class AddInventoryKindAndStorageTypeToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :inventory_kind, :string
    add_column :inventories, :storage_type, :string
  end
end
