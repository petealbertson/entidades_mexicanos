class Municipio < ApplicationRecord
  belongs_to :estado
  has_many :colonias
  
  validates :nombre, presence: true
  validates :clave, presence: true,
            format: { with: /\A\d{3}\z/, message: "must be a 3-digit number" }
  validates :clave, uniqueness: { scope: :estado_id }

  def full_clave
    "#{estado.clave}#{clave}"
  end

  def to_param
    clave
  end
end
