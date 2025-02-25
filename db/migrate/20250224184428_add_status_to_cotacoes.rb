class AddStatusToCotacoes < ActiveRecord::Migration[8.0]
  def change
    add_column :cotacaos, :status, :string
  end
end
