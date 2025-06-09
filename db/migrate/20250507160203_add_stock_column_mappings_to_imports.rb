class AddStockColumnMappingsToImports < ActiveRecord::Migration[7.2]
  def change
    add_column :imports, :asset_unit_value_col_label, :string
    add_column :imports, :storage_type_col_label, :string
    add_column :imports, :stock_type_col_label, :string
  end
end
