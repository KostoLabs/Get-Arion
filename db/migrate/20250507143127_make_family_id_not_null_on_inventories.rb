class MakeFamilyIdNotNullOnInventories < ActiveRecord::Migration[7.0]
  def change
    change_column_null :inventories, :family_id, false
  end
end
