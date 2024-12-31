class CreateMunicipios < ActiveRecord::Migration[7.1]
  def change
    create_table :municipios do |t|
      t.string :nombre
      t.string :clave
      t.references :estado, null: false, foreign_key: true

      t.timestamps
    end
  end
end
