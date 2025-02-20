class CreateCotacaos < ActiveRecord::Migration[8.0]
  def change
    create_table :cotacaos do |t|
      t.timestamps
    end
  end
end
