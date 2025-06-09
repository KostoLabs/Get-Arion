class AddZipAndCityToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :company_zip_code, :string
    add_column :users, :company_city, :string
  end
end
