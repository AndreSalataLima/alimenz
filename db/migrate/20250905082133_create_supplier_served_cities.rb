class CreateSupplierServedCities < ActiveRecord::Migration[8.0]
  def change
    create_table :supplier_served_cities do |t|
      t.references :supplier, null: false, foreign_key: { to_table: :users }
      t.references :city, null: false, foreign_key: true
      t.timestamps
    end

    add_index :supplier_served_cities,
              [ :supplier_id, :city_id ],
              unique: true,
              name: "index_unique_supplier_city"
  end
end
