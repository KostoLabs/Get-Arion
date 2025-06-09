class InventoriesController < ApplicationController
  include AccountableResource

  permitted_accountable_attributes(
    :id,
    :storage,
    :inventory_type,
    :address,
    :city,
    :region,
    :postal_code,
    :country
  )
end
