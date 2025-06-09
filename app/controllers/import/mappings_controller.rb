class Import::MappingsController < ApplicationController
  before_action :set_import

  # def update
  #   mapping = @import.mappings.find(params[:id])

  #   mapping.update! \
  #     create_when_empty: create_when_empty,
  #     mappable: mappable,
  #     value: mapping_params[:value]

  #   redirect_url = import_confirm_path(@import)
  #   Rails.logger.info "Redirection vers: #{redirect_url}"
  #   redirect_back_or_to redirect_url
  # end

  def update
    mapping = @import.mappings.find(params[:id])

    if mapping.mappable_class.present?
      mapping.update!(
        create_when_empty: create_when_empty,
        mappable: mappable,
        value: nil # important : on efface `value` pour ne pas écraser `mappable_id`
      )
    else
      mapping.update!(
        value: mapping_params[:value]
      )
    end

    redirect_back_or_to import_confirm_path(@import)
  end

  private
    def mapping_params
      params.require(:import_mapping).permit(:type, :key, :mappable_id, :mappable_type, :value)
    end

    def set_import
      @import = Current.family.imports.find(params[:import_id])
    end

    def mappable
      return nil unless mappable_class.present?

      if mappable_class == Inventory
        @mappable ||= mappable_class
          .joins(:account)
          .where(id: mapping_params[:mappable_id], accounts: { family_id: Current.family.id })
          .first
      else
        @mappable ||= mappable_class.find_by(id: mapping_params[:mappable_id], family: Current.family)
      end
    end

    def create_when_empty
      return false unless mapping_class.present?

      mapping_params[:mappable_id] == mapping_class::CREATE_NEW_KEY
    end

    def mappable_class
      mapping_params[:mappable_type]&.constantize
    end

    def mapping_class
      mapping_params[:type]&.constantize
    end
end
