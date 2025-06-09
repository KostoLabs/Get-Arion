class Import::ConfirmsController < ApplicationController
  layout "imports"

  before_action :set_import

  def create
    if @import.csv_file.attached? && @import.raw_file_str.blank?
      @import.raw_file_str = @import.csv_file.download.force_encoding("UTF-8")
    end

    @import.uploaded = true
    @import.save!

    @import.generate_rows_from_csv

    redirect_to import_path(@import), notice: t(".success")
  end

  def show
    if @import.mapping_steps.empty?
      return redirect_to import_path(@import)
    end

    unless @import.cleaned?
      return redirect_to import_clean_path(@import), alert: t(".invalid_data")
    end

    @step = params[:step].present? ? params[:step].to_i : 1
    @step = 1 if @step < 1 || @step > @import.mapping_steps.count

    @mapping_class = @import.mapping_steps[@step - 1]

    @import.sync_mappings
    @can_proceed = true
  end

  private

  def set_import
    @import = Current.family.imports.find(params[:import_id])
  end
end
