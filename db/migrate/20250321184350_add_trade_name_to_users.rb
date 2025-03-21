class AddTradeNameToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :trade_name, :string
  end
end
