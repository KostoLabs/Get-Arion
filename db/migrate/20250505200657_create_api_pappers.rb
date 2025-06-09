class CreateApiPappers < ActiveRecord::Migration[7.0]
  def change
    create_table :api_pappers, id: :uuid do |t|
      t.string :siren, null: false
      t.jsonb :response_data, null: false

      t.timestamps
    end

    add_index :api_pappers, :siren, unique: true
  end
end
