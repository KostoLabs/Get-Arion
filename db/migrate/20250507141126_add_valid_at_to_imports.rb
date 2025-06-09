class AddValidAtToImports < ActiveRecord::Migration[7.2]
  def change
    add_column :imports, :valid_at, :date
  end
end
