class CreateItemDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    create_table :item_de_cotacaos do |t|
      t.references :cotacao, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.decimal :quantidade
      t.string :unidade_selecionada

      t.timestamps
    end
  end
end
