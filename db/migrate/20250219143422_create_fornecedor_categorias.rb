class CreateFornecedorCategorias < ActiveRecord::Migration[8.0]
  def change
    create_table :fornecedor_categorias do |t|
      t.integer :fornecedor_id
      t.integer :categoria_id

      t.timestamps
    end

    add_index :fornecedor_categorias, :fornecedor_id
    add_index :fornecedor_categorias, :categoria_id
    add_foreign_key :fornecedor_categorias, :usuarios, column: :fornecedor_id
    add_foreign_key :fornecedor_categorias, :categorias, column: :categoria_id
  end
end
