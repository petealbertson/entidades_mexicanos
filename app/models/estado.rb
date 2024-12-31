class Estado < ApplicationRecord
  has_many :municipios
  has_many :colonias, through: :municipios
  
  validates :nombre, presence: true
  validates :clave, presence: true, uniqueness: true,
            format: { with: /\A\d{2}\z/, message: "must be a 2-digit number" }
  validates :abbreviation, presence: true, uniqueness: true

  def to_param
    clave
  end
end
