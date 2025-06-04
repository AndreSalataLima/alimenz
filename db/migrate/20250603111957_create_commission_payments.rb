class CreateCommissionPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :commission_payments do |t|
      t.references :commission, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :payment_date, null: false

      t.timestamps
    end
  end
end
