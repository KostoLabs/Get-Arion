class ChangeFinancialLiabilitiesColumnsNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :financial_liabilities, :lending_type, true
    change_column_null :financial_liabilities, :lending_rate_type, true
    change_column_null :financial_liabilities, :lending_rate, true
    change_column_null :financial_liabilities, :lending_start, true
    change_column_null :financial_liabilities, :lending_close, true
    change_column_null :financial_liabilities, :lenders, true
    change_column_null :financial_liabilities, :collateral, true
    change_column_null :financial_liabilities, :haircut, true
    change_column_null :financial_liabilities, :collateral_floor, true
  end
end
