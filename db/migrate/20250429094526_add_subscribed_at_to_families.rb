class AddSubscribedAtToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :subscribed_at, :datetime
  end
end
