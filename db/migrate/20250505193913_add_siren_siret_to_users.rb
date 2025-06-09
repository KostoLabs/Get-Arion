class AddSirenSiretToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :siren_siret, :string
  end
end
