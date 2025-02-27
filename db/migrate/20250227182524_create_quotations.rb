class CreateQuotations < ActiveRecord::Migration[8.0]
  def change
    create_table :quotations do |t|
      t.date :expiration_date, null: false
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.string :status, default: "pendente", null: false

      t.timestamps
    end
  end
end
