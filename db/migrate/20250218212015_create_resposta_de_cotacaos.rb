class CreateRespostaDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    create_table :resposta_de_cotacaos do |t|
      t.timestamps
    end
  end
end
