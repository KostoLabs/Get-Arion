class RemoveSirenSiretFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :siren_siret, :string
  end
end
