class AddFamilyIdToInventories < ActiveRecord::Migration[7.2]
  def change
    add_reference :inventories, :family, null: true, foreign_key: true, type: :uuid
  end
end
