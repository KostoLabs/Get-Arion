class CleanUpImportRowsInventoryFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :import_rows, :asset_unit_value, :string
    remove_column :import_rows, :stock_type, :string
    remove_column :import_rows, :storage_type, :string
    remove_column :import_rows, :stock_name, :string
  end
end
