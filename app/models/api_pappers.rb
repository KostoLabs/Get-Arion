class ApiPappers < ApplicationRecord
  validates :siren, presence: true, uniqueness: true
  
end
