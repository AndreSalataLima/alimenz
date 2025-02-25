class CreatePedidoDeCompraItems < ActiveRecord::Migration[8.0]
  def change
    create_table :pedido_de_compra_items do |t|
      t.references :pedido_de_compra, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.decimal :quantidade, precision: 10, scale: 2, default: 0
      t.string :unidade
      t.decimal :preco, precision: 10, scale: 2, default: 0
      t.timestamps
    end
  end
end
