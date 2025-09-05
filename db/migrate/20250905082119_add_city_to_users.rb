class AddCityToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :city, foreign_key: true
  end
end
