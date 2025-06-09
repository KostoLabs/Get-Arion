class Corporate < ApplicationRecord
  belongs_to :family
  belongs_to :user

  validates :siren, presence: true
  validates :name, presence: true
end
