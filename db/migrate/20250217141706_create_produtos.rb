class CreateProdutos < ActiveRecord::Migration[8.0]
  def change
    create_table :produtos do |t|
      t.string :nome
      t.integer :categoria_id
      t.integer :subcategoria_id
      t.string :marca
      t.string :unidade_sugerida
      t.string :nome_generico
      t.decimal :commission_percentage

      t.timestamps
    end
  end
end
