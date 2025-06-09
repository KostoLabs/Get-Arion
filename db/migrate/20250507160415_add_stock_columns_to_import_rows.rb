class AddStockColumnsToImportRows < ActiveRecord::Migration[7.2]
  def change
    add_column :import_rows, :asset_unit_value, :string
    add_column :import_rows, :storage_type, :string
    add_column :import_rows, :stock_type, :string
  end
end
