require "ostruct"

class ContactMailer < ApplicationMailer
  default from: ENV["EMAIL_USERNAME"] # Utiliser l'adresse Gmail comme expéditeur

  def contact_email(message)
    @message = message
    mail(
      to: "camille@get-arion.io",  # Adresse de réception
      from: ENV["EMAIL_USERNAME"], # Envoyer depuis l'adresse Gmail
      subject: "Nouveau message de contact - Arion"
    )
  end
end
