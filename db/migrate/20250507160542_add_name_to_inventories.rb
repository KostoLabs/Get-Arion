class AddNameToInventories < ActiveRecord::Migration[7.2]
  def change
    add_column :inventories, :name, :string
  end
end
