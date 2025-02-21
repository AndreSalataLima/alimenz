class AddDisponibilidadeToRespostaDeCotacaoItems < ActiveRecord::Migration[8.0]
  def change
    add_column :resposta_de_cotacao_items, :disponivel, :boolean, default: true, null: false
  end
end
