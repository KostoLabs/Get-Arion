class CreateCorporates < ActiveRecord::Migration[7.2]
  def change
    create_table :corporates, id: :uuid do |t|
      t.string :name
      t.string :address
      t.string :naf
      t.date :creation_date
      t.string :siren
      t.references :family, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
