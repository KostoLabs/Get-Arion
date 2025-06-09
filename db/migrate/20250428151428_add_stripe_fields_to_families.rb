class AddStripeFieldsToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :stripe_premium_plan_id, :string
    add_column :families, :stripe_premium_subscription_status, :string
  end
end
