class FornecedorCategoria < ApplicationRecord
  belongs_to :fornecedor, class_name: "Usuario", foreign_key: "fornecedor_id"
  belongs_to :categoria
end
