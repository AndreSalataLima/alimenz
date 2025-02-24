class CreatePedidoDeCompras < ActiveRecord::Migration[8.0]
  def change
    create_table :pedido_de_compras do |t|
      # Referenciando a tabela "usuarios", já que o modelo unificado é Usuario.
      t.references :cliente, null: false, foreign_key: { to_table: :usuarios }
      t.references :fornecedor, null: false, foreign_key: { to_table: :usuarios }
      t.decimal :valor_total, precision: 10, scale: 2, null: false, default: "0.0"
      t.date :data_validade, null: false
      t.string :status, null: false, default: "pendente"
      t.jsonb :itens, default: {}

      t.timestamps
    end
  end
end
