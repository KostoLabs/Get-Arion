class ChangeDefaultTimezoneToFamilies < ActiveRecord::Migration[7.2]
  def up
    change_column_default :families, :timezone, "Europe/Paris"
    Family.where(timezone: nil).update_all(timezone: "Europe/Paris") # Met à jour les valeurs NULL existantes
  end

  def down
    change_column_default :families, :timezone, nil
  end
end
