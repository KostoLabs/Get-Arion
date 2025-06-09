class AddCustomerPlaceToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :asset_customer_place, :string
  end
end
