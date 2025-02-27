class CreateQuotationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :quotation_items do |t|
      t.references :quotation, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, null: false
      t.string :selected_unit, null: false
      t.boolean :keep_generic_name

      t.timestamps
    end
  end
end
