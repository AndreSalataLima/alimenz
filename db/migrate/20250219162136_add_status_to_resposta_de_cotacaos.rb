class AddStatusToRespostaDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :resposta_de_cotacaos, :status, :string, default: "pendente"
  end
end
