class AddClienteIdToCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :cotacaos, :cliente_id, :integer
  end
end
