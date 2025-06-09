class RenamePropertiesToInventories < ActiveRecord::Migration[7.0]
  def change
    rename_table :properties, :inventories
  end
end
