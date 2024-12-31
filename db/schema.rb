# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_31_045331) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "colonias", force: :cascade do |t|
    t.string "nombre"
    t.decimal "latitud", precision: 10, scale: 6
    t.decimal "longitud", precision: 10, scale: 6
    t.decimal "altitud_msm", precision: 8, scale: 2
    t.bigint "municipio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "clave"
    t.index ["municipio_id"], name: "index_colonias_on_municipio_id"
  end

  create_table "estados", force: :cascade do |t|
    t.string "nombre"
    t.string "clave"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "municipios", force: :cascade do |t|
    t.string "nombre"
    t.string "clave"
    t.bigint "estado_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado_id"], name: "index_municipios_on_estado_id"
  end

  add_foreign_key "colonias", "municipios"
  add_foreign_key "municipios", "estados"
end
