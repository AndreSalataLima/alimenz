class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :generic_name
      t.string :brand
      t.string :unit_options, array: true, default: []
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
