class InventoryImport < Import
  def import!
    transaction do
      inventories_updated = Hash.new { |h, k| h[k] = [] }

      # Utiliser les mappings pour assigner les inventaires aux lignes
      rows.each do |row|
        mapping = mappings.find_by(key: row.asset_customer_id, type: "Import::InventoryMapping")
        next unless mapping&.value.present?

        inventory = mapping.mappable
        next unless inventory.present?

        row.update!(
          inventory: inventory,
          asset_customer_place: inventory.asset_customer_place
        )

        inventories_updated[inventory] << row
      end

      log_import_progress("Processing #{inventories_updated.keys.count} inventories with #{rows.count} rows")

      inventories_updated.each do |inventory, associated_rows|
        account = inventory.account
        unless account&.is_active?
          log_import_progress("Skipping inventory #{inventory.id} - no active account found")
          next
        end

        # Calculer la valeur totale à partir du CSV
        total_value = associated_rows.sum { |row| row.asset_value.to_d }
        log_import_progress("Calculated total value from CSV: #{total_value}")

        # Date d'import - TOUJOURS utiliser la date courante pour éviter les problèmes de sync
        import_date = Date.current  # Pas de date future !

        # COMME DEPOSITORY: Créer/mettre à jour une Account::Valuation
        existing_entry = account.entries.account_valuations.find_by(date: import_date)

        if existing_entry
          log_import_progress("Updating existing valuation entry for date #{import_date}")
          # Mettre à jour l'entrée existante
          existing_entry.update!(amount: total_value)
          # La balance sera automatiquement mise à jour via le callback
        else
          log_import_progress("Creating new valuation entry for date #{import_date}")
          # Créer une nouvelle entrée avec Account::Valuation
          account.entries.create!(
            amount: total_value,
            currency: account.currency,
            date: import_date,
            name: "Import de stock - #{associated_rows.size} articles",
            entryable: Account::Valuation.new  # Juste créer une instance vide
          )
          # La balance sera automatiquement mise à jour via le callback
          log_import_progress("Created valuation entry with amount #{total_value}")
        end

        # Déclencher la synchronisation comme pour Depository
        begin
          inventory.post_sync if inventory.respond_to?(:post_sync)
          log_import_progress("Triggered post_sync for inventory #{inventory.id}")
        rescue => e
          log_import_progress("post_sync failed: #{e.message}")
        end

        begin
          account.sync_later if account.respond_to?(:sync_later)
          log_import_progress("Triggered sync_later for account #{account.id}")
        rescue => e
          log_import_progress("sync_later failed: #{e.message}")
        end

        # CORRECTION: S'assurer que la balance reflète la valuation la plus récente en date
        account.reload
        latest_valuation = account.entries.account_valuations.order(:date).last
        if latest_valuation
          account.update!(balance: latest_valuation.amount)
          log_import_progress("Balance corrected to match latest valuation: #{latest_valuation.amount}")
        end
      end

      # Marquer l'import comme terminé
      update!(status: :complete)
      log_import_progress("Import completed successfully")

      # Déclencher une synchronisation famille
      begin
        family.sync_later if family.respond_to?(:sync_later)
        log_import_progress("Triggered family sync")
      rescue => e
        log_import_progress("Family sync failed: #{e.message}")
      end
    end
  rescue => e
    log_import_progress("Import failed with error: #{e.message}")
    Rails.logger.error "InventoryImport #{id} failed: #{e.message}\n#{e.backtrace.join("\n")}"
    update!(status: :failed) if respond_to?(:status)
    raise e
  end

  def generate_rows_from_csv
    rows.destroy_all

    mapped_rows = parsed_csv.map do |row|
      {
        asset_customer_id: row[asset_customer_id_col_label],
        asset_description: row[asset_description_col_label],
        asset_type: row[asset_type_col_label],
        asset_qty: sanitize_number(row[asset_qty_col_label]),
        asset_unit: row[asset_unit_col_label],
        asset_item_value: sanitize_number(row[asset_item_value_col_label]),
        asset_value: sanitize_number(row[asset_value_col_label]),
        asset_category: row[asset_category_col_label],
        asset_entry_date: row[asset_entry_date_col_label],
        asset_out_date: row[asset_out_date_col_label],
        asset_place_id: row[asset_place_id_col_label],
        transaction_uuid: SecureRandom.uuid
      }
    end

    rows.insert_all!(mapped_rows)
  end

  def mapping_steps
    [Import::InventoryMapping]
  end

  def required_column_keys
    %i[
      asset_customer_id asset_description asset_qty asset_unit
      asset_item_value asset_value asset_place_id
    ]
  end

  def column_keys
    %i[
      asset_customer_id asset_description asset_type
      asset_qty asset_unit asset_item_value asset_value
      asset_category asset_entry_date asset_out_date asset_place_id
    ]
  end

  def csv_template
    CSV.parse(<<~CSV, headers: true)
      Numéro article*,Nom article*,Type,Quantité*,Unité*,Valeur unitaire*,Valeur totale*,Catégorie,Date entrée,Date sortie,Emplacement*
      A001,Vis acier,,100,pcs,0.50,50.0,Quincaillerie,2024-01-01,2024-06-01,E01
    CSV
  end

  def display_name
    "Import d'inventaire du #{created_at.strftime('%d/%m/%Y')}"
  end

  def dry_run
    {
      inventories: mappings.where(type: "Import::InventoryMapping").where.not(value: nil).count,
      articles: rows.count
    }
  end

  private

    def log_import_progress(message)
      Rails.logger.info "[InventoryImport] #{id}: #{message}"
    end
end


# class InventoryImport < Import
#   def import!
#     transaction do
#       inventories_updated = Hash.new { |h, k| h[k] = [] }

#       rows.each do |row|
#         mapping = mappings.find_by(key: row.asset_customer_id, type: "Import::InventoryMapping")
#         next unless mapping&.mappable.present?

#         inventory = mapping.mappable
#         row.update!(
#           inventory: inventory,
#           asset_customer_place: inventory.asset_customer_place
#         )

#         inventories_updated[inventory] << row
#       end

#       inventories_updated.each do |inventory, associated_rows|
#         account = family.accounts.find_by(accountable: inventory)
#         next unless account

#         total_value = associated_rows.sum { |r| r.asset_value.to_d }
#         account.update!(balance: total_value)

#         # Chercher une entrée existante pour cette date ou en créer une nouvelle
#         import_date = valid_at || Date.current
#         existing_entry = account.entries.account_valuations.find_by(date: import_date)

#         if existing_entry
#           # Mettre à jour l'entrée existante
#           existing_entry.update!(amount: total_value)
#         else
#           # Créer une nouvelle entrée
#           account.entries.create!(
#             amount: total_value,
#             currency: account.currency,
#             date: import_date,
#             name: "Import d'inventaire - #{associated_rows.size} articles",
#             entryable: Account::Valuation.new
#           )
#         end
#       end
#     end
#   end


#   def generate_rows_from_csv
#     rows.destroy_all

#     mapped_rows = parsed_csv.map do |row|
#       {
#         asset_customer_id: row[asset_customer_id_col_label],
#         asset_description: row[asset_description_col_label],
#         asset_type: row[asset_type_col_label],
#         asset_qty: sanitize_number(row[asset_qty_col_label]),
#         asset_unit: row[asset_unit_col_label],
#         asset_item_value: sanitize_number(row[asset_item_value_col_label]),
#         asset_value: sanitize_number(row[asset_value_col_label]),
#         asset_category: row[asset_category_col_label],
#         asset_entry_date: row[asset_entry_date_col_label],
#         asset_out_date: row[asset_out_date_col_label],
#         asset_place_id: row[asset_place_id_col_label],
#         transaction_uuid: SecureRandom.uuid
#       }
#     end

#     rows.insert_all!(mapped_rows)
#   end

#   def mapping_steps
#   [Import::InventoryMapping]
#   end

#   def required_column_keys
#     %i[
#       asset_customer_id asset_description asset_qty asset_unit
#       asset_item_value asset_value asset_place_id
#     ]
#   end

#   def column_keys
#     %i[
#       asset_customer_id asset_description asset_type
#       asset_qty asset_unit asset_item_value asset_value
#       asset_category asset_entry_date asset_out_date asset_place_id
#     ]
#   end

#   def csv_template
#     CSV.parse(<<~CSV, headers: true)
#       Numéro article*,Nom article*,Type,Quantité*,Unité*,Valeur unitaire*,Valeur totale*,Catégorie,Date entrée,Date sortie,Emplacement*
#       A001,Vis acier,,100,pcs,0.50,50.0,Quincaillerie,2024-01-01,2024-06-01,E01
#     CSV
#   end

#   def display_name
#     "Import d’inventaire du #{created_at.strftime('%d/%m/%Y')}"
#   end

#   def dry_run
#     {
#       # Utilisez value au lieu de mappable
#       inventories: mappings.where(type: "Import::InventoryMapping").where.not(value: nil).count,
#       articles: rows.count
#     }
#   end
# end
