class AddManterNomeGenericoToItemDeCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :item_de_cotacaos, :manter_nome_generico, :boolean
  end
end
