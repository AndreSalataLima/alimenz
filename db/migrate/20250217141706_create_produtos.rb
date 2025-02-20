class CreateProdutos < ActiveRecord::Migration[8.0]
  def change
    create_table :produtos do |t|
      t.string :nome_generico
      t.string :marca
      t.integer :categoria_id
      t.integer :subcategoria_id
      t.string :unidade_sugerida
      t.decimal :commission_percentage

      t.timestamps
    end
  end
end
