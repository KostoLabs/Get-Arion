class AddStockFieldsToImportRows < ActiveRecord::Migration[7.2]
  def change
    add_column :import_rows, :stock_name, :string
    add_column :import_rows, :transaction_uuid, :string
    add_column :import_rows, :asset_customer_place, :string
  end
end
