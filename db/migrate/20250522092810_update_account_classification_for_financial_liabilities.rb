class UpdateAccountClassificationForFinancialLiabilities < ActiveRecord::Migration[7.1]
  def up
    # Supprimer la colonne existante
    remove_column :accounts, :classification

    # Recréer la colonne avec le nouveau type inclus
    execute <<~SQL
      ALTER TABLE accounts
      ADD COLUMN classification VARCHAR GENERATED ALWAYS AS (
        CASE
          WHEN accountable_type IN ('Loan', 'CreditCard', 'OtherLiability', 'FinancialLiability')
          THEN 'liability'
          ELSE 'asset'
        END
      ) STORED
    SQL
  end

  def down
    # Supprimer à nouveau pour rollback
    remove_column :accounts, :classification

    # Recréer l’ancienne version sans FinancialLiability
    execute <<~SQL
      ALTER TABLE accounts
      ADD COLUMN classification VARCHAR GENERATED ALWAYS AS (
        CASE
          WHEN accountable_type IN ('Loan', 'CreditCard', 'OtherLiability')
          THEN 'liability'
          ELSE 'asset'
        END
      ) STORED
    SQL
  end
end
