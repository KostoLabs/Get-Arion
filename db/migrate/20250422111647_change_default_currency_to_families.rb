class ChangeDefaultCurrencyToFamilies < ActiveRecord::Migration[7.2]
  def up
    change_column_default :families, :currency, "EUR"
    Family.where(currency: "USD").update_all(currency: "EUR") # Change les valeurs existantes
  end

  def down
    change_column_default :families, :currency, "USD"
  end
end
