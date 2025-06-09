class FinancialLiabilitiesController < ApplicationController
  include AccountableResource

  permitted_accountable_attributes(
    :id,
    :lending_type,
    :lending_rate,
    :lending_rate_type,
    :lending_start,
    :lending_close,
    :lenders,
    :collateral,
    :haircut,
    :collateral_floor
  )
end
