class ContactMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :subject, :content

  validates :name, presence: { message: "Le nom est requis." }
  validates :email, presence: { message: "L'email est requis." }, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Format d'email invalide." }
  validates :subject, presence: { message: "Le sujet est requis." }
  validates :content, presence: { message: "Le message ne peut pas être vide." }
end
