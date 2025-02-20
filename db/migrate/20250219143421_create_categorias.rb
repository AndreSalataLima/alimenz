class CreateCategorias < ActiveRecord::Migration[8.0]
  def change
    create_table :categorias do |t|
      t.string :nome, null: false
      t.text :descricao

      t.timestamps
    end

    add_index :categorias, :nome, unique: true
  end
end
