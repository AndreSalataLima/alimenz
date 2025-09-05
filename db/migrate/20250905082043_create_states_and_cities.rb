class CreateStatesAndCities < ActiveRecord::Migration[8.0]
  def change
    create_table :states do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.timestamps
    end
    add_index :states, :code, unique: true

    create_table :cities do |t|
      t.string :name, null: false
      t.references :state, null: false, foreign_key: true
      t.timestamps
    end
    add_index :cities, [:state_id, :name], unique: true
  end
end
