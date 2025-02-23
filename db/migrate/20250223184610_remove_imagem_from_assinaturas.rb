class RemoveImagemFromAssinaturas < ActiveRecord::Migration[8.0]
  def change
    remove_column :assinaturas, :imagem, :text
  end
end
