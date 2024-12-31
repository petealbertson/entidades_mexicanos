class Colonia < ApplicationRecord
  belongs_to :municipio
  has_one :estado, through: :municipio
  
  validates :nombre, presence: true
  validates :latitud, presence: true
  validates :longitud, presence: true
  
  def full_location
    "#{nombre}, #{municipio.nombre}, #{estado.nombre}"
  end
end
