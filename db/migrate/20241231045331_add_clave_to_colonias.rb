class AddClaveToColonias < ActiveRecord::Migration[7.1]
  def change
    add_column :colonias, :clave, :string
  end
end
