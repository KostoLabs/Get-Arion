class AddInventoryToImportRows < ActiveRecord::Migration[7.2]
  def change
    add_column :import_rows, :inventory_id, :uuid
  end
end
