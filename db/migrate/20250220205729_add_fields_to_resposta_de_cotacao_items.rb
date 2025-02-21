class AddFieldsToRespostaDeCotacaoItems < ActiveRecord::Migration[8.0]
  def change
    change_table :resposta_de_cotacao_items do |t|
      t.integer :resposta_de_cotacao_id, null: false
      t.integer :item_de_cotacao_id, null: false
      t.decimal :preco, precision: 10, scale: 2, default: 0.0, null: false
    end

    add_index :resposta_de_cotacao_items, :resposta_de_cotacao_id
    add_index :resposta_de_cotacao_items, :item_de_cotacao_id

    add_foreign_key :resposta_de_cotacao_items, :resposta_de_cotacaos, column: :resposta_de_cotacao_id
    add_foreign_key :resposta_de_cotacao_items, :item_de_cotacaos, column: :item_de_cotacao_id
  end
end
