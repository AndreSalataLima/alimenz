class CreateQuotationResponseItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quotation_response_items do |t|
      t.references :quotation_response, null: false, foreign_key: true
      t.references :quotation_item, null: false, foreign_key: true
      t.boolean :available, default: true, null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0, null: false

      t.timestamps
    end
  end
end
