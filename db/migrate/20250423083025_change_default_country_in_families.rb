class ChangeDefaultCountryInFamilies < ActiveRecord::Migration[7.2]
  def change
    change_column_default :families, :country, "FR"
  end
end
