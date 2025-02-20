class AddForeignKeysToRespostaDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :resposta_de_cotacaos, :cotacao_id, :integer
    add_column :resposta_de_cotacaos, :fornecedor_id, :integer

    add_index :resposta_de_cotacaos, :cotacao_id
    add_index :resposta_de_cotacaos, :fornecedor_id

    add_foreign_key :resposta_de_cotacaos, :cotacaos, column: :cotacao_id
    add_foreign_key :resposta_de_cotacaos, :usuarios, column: :fornecedor_id
  end
end
