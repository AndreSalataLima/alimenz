class CreateBlockedSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :blocked_suppliers do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :blocked_suppliers, [:customer_id, :supplier_id], unique: true, name: "index_blocked_on_customer_and_supplier"
  end
end
