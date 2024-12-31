class CreateColonias < ActiveRecord::Migration[7.1]
  def change
    create_table :colonias do |t|
      t.string :nombre
      t.decimal :latitud, precision: 10, scale: 6
      t.decimal :longitud, precision: 10, scale: 6
      t.decimal :altitud_msm, precision: 8, scale: 2
      t.references :municipio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
