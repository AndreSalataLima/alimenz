class AddOpcoesUnidadesToProdutos < ActiveRecord::Migration[8.0]
  def change
    add_column :produtos, :opcoes_unidades, :string, array: true, default: []
    remove_column :produtos, :unidade_sugerida, :string
  end
end
