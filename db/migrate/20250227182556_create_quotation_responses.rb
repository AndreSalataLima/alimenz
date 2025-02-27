class CreateQuotationResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :quotation_responses do |t|
      t.references :quotation, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "pendente", null: false
      t.date :expiration_date
      t.string :analysis_status, default: "pendente_de_analise", null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0, null: false


      t.timestamps
    end
  end
end
