class CreateEstados < ActiveRecord::Migration[7.1]
  def change
    create_table :estados do |t|
      t.string :nombre
      t.string :clave
      t.string :abbreviation

      t.timestamps
    end
  end
end
