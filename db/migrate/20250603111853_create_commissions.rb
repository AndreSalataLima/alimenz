class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :purchase_order, null: false, foreign_key: true, index: { unique: true }
      t.decimal :total_commission, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
