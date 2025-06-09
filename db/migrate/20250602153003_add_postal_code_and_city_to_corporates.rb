class AddPostalCodeAndCityToCorporates < ActiveRecord::Migration[7.0]
  def change
    add_column :corporates, :postal_code, :string
    add_column :corporates, :city, :string
  end
end
