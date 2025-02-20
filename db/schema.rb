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

ActiveRecord::Schema[8.0].define(version: 2025_02_19_162431) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categorias", force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_categorias_on_nome", unique: true
  end

  create_table "cotacaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "data_validade"
    t.integer "cliente_id"
  end

  create_table "fornecedor_categorias", force: :cascade do |t|
    t.integer "fornecedor_id"
    t.integer "categoria_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categoria_id"], name: "index_fornecedor_categorias_on_categoria_id"
    t.index ["fornecedor_id"], name: "index_fornecedor_categorias_on_fornecedor_id"
  end

  create_table "item_de_cotacaos", force: :cascade do |t|
    t.bigint "cotacao_id", null: false
    t.bigint "produto_id", null: false
    t.decimal "quantidade"
    t.string "unidade_selecionada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "manter_nome_generico"
    t.index ["cotacao_id"], name: "index_item_de_cotacaos_on_cotacao_id"
    t.index ["produto_id"], name: "index_item_de_cotacaos_on_produto_id"
  end

  create_table "produto_customizados", force: :cascade do |t|
    t.integer "cliente_id"
    t.integer "produto_id"
    t.string "nome_customizado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "produtos", force: :cascade do |t|
    t.string "nome_generico"
    t.string "marca"
    t.integer "categoria_id"
    t.integer "subcategoria_id"
    t.decimal "commission_percentage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "opcoes_unidades", default: [], array: true
  end

  create_table "resposta_de_cotacaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "cotacao_id"
    t.integer "fornecedor_id"
    t.string "status", default: "pendente"
    t.date "data_validade"
    t.index ["cotacao_id"], name: "index_resposta_de_cotacaos_on_cotacao_id"
    t.index ["fornecedor_id"], name: "index_resposta_de_cotacaos_on_fornecedor_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "nome", null: false
    t.string "papel", default: "cliente", null: false
    t.string "cnpj"
    t.string "responsavel"
    t.text "endereco"
    t.text "logo"
    t.text "company_stamp"
    t.decimal "commission_percentage"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  add_foreign_key "fornecedor_categorias", "categorias"
  add_foreign_key "fornecedor_categorias", "usuarios", column: "fornecedor_id"
  add_foreign_key "item_de_cotacaos", "cotacaos"
  add_foreign_key "item_de_cotacaos", "produtos"
  add_foreign_key "resposta_de_cotacaos", "cotacaos"
  add_foreign_key "resposta_de_cotacaos", "usuarios", column: "fornecedor_id"
end
