class Import::UploadsController < ApplicationController
  layout "imports"

  before_action :set_import

  def show
  end

  def update
    if csv_valid?(csv_str)
      @import.account = Current.family.accounts.find_by(id: params.dig(:import, :account_id))
      @import.assign_attributes(raw_file_str: csv_str, col_sep: upload_params[:col_sep], valid_at: upload_params[:valid_at])
      @import.save!(validate: false)

      redirect_to import_configuration_path(@import, template_hint: true), notice: "CSV chargé avec succès."
    else
      flash.now[:alert] = "Le fichier doit être un CSV valide avec des en-têtes et au moins une ligne de données."

      render :show, status: :unprocessable_entity
    end
  end

  def download_template
    filename = "Template-csv-import-stocks.csv"
    send_data @import.csv_template.to_csv, filename: filename, type: "text/csv"
  end

  private
    def set_import
      @import = Current.family.imports.find(params[:import_id])
    end

    def csv_str
      @csv_str ||= upload_params[:csv_file]&.read || upload_params[:raw_file_str]
    end

    def csv_valid?(str)
      begin
        csv = Import.parse_csv_str(str, col_sep: upload_params[:col_sep])
        return false if csv.headers.empty?
        return false if csv.count == 0
        true
      rescue CSV::MalformedCSVError
        false
      end
    end

    def upload_params
      params.require(:import).permit(:raw_file_str, :csv_file, :col_sep, :valid_at)
    end
end
