class ImportsController < ApplicationController
  before_action :set_import, only: %i[show publish destroy revert apply_template]
  before_action :require_import_subscription!, only: [:new, :create]

  def publish
    @import.publish_later
    redirect_to import_path(@import), notice: "Votre import a démarré en arrière-plan."
  end

  def index
    @imports = Current.family.imports
    render layout: "settings"
  end

  def new
    @pending_import = Current.family.imports.ordered.pending.first
  end

  def create
    account = Current.family.accounts.find_by(id: params.dig(:import, :account_id))
    import = Current.family.imports.create!(
      type: import_params[:type],
      account: account,
      date_format: Current.family.date_format,
    )

    redirect_to import_upload_path(import)
  end

  def show
    if !@import.uploaded?
      redirect_to import_upload_path(@import), alert: "Merci de finaliser l'importation de votre fichier."
    elsif !@import.publishable?
      redirect_to import_confirm_path(@import), alert: "Merci de finaliser vos correspondances avant de continuer."
    end
  end

  def revert
    @import.revert_later
    redirect_to imports_path, notice: "L'importation est en cours d'annulation en arrière-plan."
  end

  def apply_template
    if @import.suggested_template
      @import.apply_template!(@import.suggested_template)
      redirect_to import_configuration_path(@import), notice: "Le modèle a été appliqué."
    else
      redirect_to import_configuration_path(@import), alert: "Aucun modèle trouvé, merci de configurer votre import manuellement."
    end
  end

  def destroy
    @import.destroy
    redirect_to imports_path, notice: "Import supprimé avec succès."
  end

  def bulk_assign_inventory_mappings
    import = InventoryImport.find(params[:id])
    inventory_id = params[:inventory_id]

    if inventory_id.blank?
      return redirect_to import_confirm_path(import), alert: "Aucun stock sélectionné"
    end

    import.mappings
          .where(type: "Import::InventoryMapping")
          .update_all(value: inventory_id)

    redirect_to import_confirm_path(import), notice: "Tous les produits ont été assignés à ce stock."
  end


  private

    def set_import
      @import = Current.family.imports.find(params[:id])
    end

    def import_params
      params.require(:import).permit(:type)
    end
end
