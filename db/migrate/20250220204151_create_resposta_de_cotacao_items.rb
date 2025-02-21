class CreateRespostaDeCotacaoItems < ActiveRecord::Migration[8.0]
  def change
    create_table :resposta_de_cotacao_items do |t|
      t.timestamps
    end
  end
end
