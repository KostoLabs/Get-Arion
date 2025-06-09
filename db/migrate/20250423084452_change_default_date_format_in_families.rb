class ChangeDefaultDateFormatInFamilies < ActiveRecord::Migration[7.2]
  def change
    change_column_default :families, :date_format, "%d/%m/%Y"
  end
end
