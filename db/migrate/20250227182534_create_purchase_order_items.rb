class CreatePurchaseOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :unit
      t.decimal :quantity, precision: 10, scale: 2, default: 0.0
      t.decimal :price, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
