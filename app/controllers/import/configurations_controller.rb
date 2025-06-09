class Import::ConfigurationsController < ApplicationController
  layout "imports"

  before_action :set_import

  def show
  end

  def update
    @import.update!(import_params)
    @import.generate_rows_from_csv
    @import.reload.sync_mappings

    redirect_to import_clean_path(@import), notice: "Import configuré avec succès."
  end

  private
    def set_import
      @import = Current.family.imports.find(params[:import_id])
    end

    def import_params
      params.require(:import).permit(
        :date_col_label,
        :amount_col_label,
        :name_col_label,
        :category_col_label,
        :tags_col_label,
        :account_col_label,
        :qty_col_label,
        :ticker_col_label,
        :exchange_operating_mic_col_label,
        :price_col_label,
        :entity_type_col_label,
        :notes_col_label,
        :currency_col_label,
        :date_format,
        :number_format,
        :signage_convention,
        :asset_unit_value_col_label,
        :storage_type_col_label,
        :stock_type_col_label,

        # les colonnes spécifiques au stock :
        :asset_customer_id_col_label,
        :asset_description_col_label,
        :asset_qty_col_label,
        :asset_unit_col_label,
        :asset_item_value_col_label,
        :asset_value_col_label,
        :asset_place_id_col_label,
        :asset_type_col_label,
        :asset_category_col_label,
        :asset_entry_date_col_label,
        :asset_out_date_col_label
      )
    end
end
