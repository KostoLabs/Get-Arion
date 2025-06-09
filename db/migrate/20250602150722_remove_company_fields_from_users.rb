class RemoveCompanyFieldsFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :company_name, :string if column_exists?(:users, :company_name)
    remove_column :users, :company_address, :string if column_exists?(:users, :company_address)
    remove_column :users, :company_naf, :string if column_exists?(:users, :company_naf)
    remove_column :users, :company_creation_date, :date if column_exists?(:users, :company_creation_date)
    remove_column :users, :company_zip_code, :string if column_exists?(:users, :company_zip_code)
    remove_column :users, :company_city, :string if column_exists?(:users, :company_city)
    remove_column :users, :siren, :string if column_exists?(:users, :siren)
  end
end
