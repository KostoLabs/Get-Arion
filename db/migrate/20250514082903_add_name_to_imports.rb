class AddNameToImports < ActiveRecord::Migration[7.2]
  def change
    add_column :imports, :name, :string
  end
end
