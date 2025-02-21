class CreateAssinaturas < ActiveRecord::Migration[8.0]
  def change
    create_table :assinaturas do |t|
      t.references :usuario, null: false, foreign_key: true
      t.text :imagem

      t.timestamps
    end
  end
end
