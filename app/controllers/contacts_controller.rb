class ContactsController < ApplicationController
  def new
    @message = ContactMessage.new
  end

  def create
    Rails.logger.info ">>> ContactController#create a été appelé"
    Rails.logger.info ">>> Paramètres reçus : #{params.inspect}"

    @message = ContactMessage.new(message_params)

    if @message.valid?
      Rails.logger.info ">>> Validation réussie, envoi de l'email..."
      ContactMailer.contact_email(@message).deliver_now
      flash[:notice] = "Votre message a bien été envoyé au centre de relation client."
      redirect_to root_path
    else
      Rails.logger.info ">>> Erreur de validation : #{@message.errors.full_messages.join(", ")}"
      flash[:alert] = "Une erreur est survenue : #{@message.errors.full_messages.join(", ")}"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:contact_message).permit(:name, :email, :subject, :content)
  end
end
