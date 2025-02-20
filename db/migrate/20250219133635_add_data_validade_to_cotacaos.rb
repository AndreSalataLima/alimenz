class AddDataValidadeToCotacaos < ActiveRecord::Migration[8.0]
  def change
    add_column :cotacaos, :data_validade, :date
  end
end
