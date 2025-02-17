class CreateProdutoCustomizados < ActiveRecord::Migration[8.0]
  def change
    create_table :produto_customizados do |t|
      t.integer :cliente_id
      t.integer :produto_id
      t.string :nome_customizado

      t.timestamps
    end
  end
end
