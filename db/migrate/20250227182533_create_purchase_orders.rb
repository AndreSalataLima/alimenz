class CreatePurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_orders do |t|
      t.date :expiration_date
      t.string :status, default: "pendente", null: false
      t.decimal :total_value, precision: 10, scale: 2, default: "0.0", null: false
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :supplier, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
