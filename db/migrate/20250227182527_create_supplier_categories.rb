class CreateSupplierCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :supplier_categories do |t|
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
