class AddStatusAnaliseToRespostaDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :resposta_de_cotacaos, :status_analise, :string, default: "pendente_de_analise"
  end
end
