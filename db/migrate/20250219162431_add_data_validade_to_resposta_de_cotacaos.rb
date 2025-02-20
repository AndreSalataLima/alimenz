class AddDataValidadeToRespostaDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :resposta_de_cotacaos, :data_validade, :date
  end
end
