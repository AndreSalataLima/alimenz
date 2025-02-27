class CreateCustomizedProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :customized_products do |t|
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :product, null: false, foreign_key: true
      t.string :custom_name, null: false

      t.timestamps
    end
  end
end
