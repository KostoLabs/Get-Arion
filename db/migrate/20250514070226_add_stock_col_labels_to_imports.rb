class AddStockColLabelsToImports < ActiveRecord::Migration[7.2]
  def change
    add_column :imports, :asset_customer_id_col_label, :string
    add_column :imports, :asset_description_col_label, :string
    add_column :imports, :asset_qty_col_label, :string
    add_column :imports, :asset_unit_col_label, :string
    add_column :imports, :asset_item_value_col_label, :string
    add_column :imports, :asset_value_col_label, :string
    add_column :imports, :asset_place_id_col_label, :string
    add_column :imports, :asset_type_col_label, :string
    add_column :imports, :asset_category_col_label, :string
    add_column :imports, :asset_entry_date_col_label, :string
    add_column :imports, :asset_out_date_col_label, :string
  end
end
