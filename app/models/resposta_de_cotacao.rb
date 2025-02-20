class RespostaDeCotacao < ApplicationRecord
  self.table_name = "resposta_de_cotacaos"

  belongs_to :cotacao
  belongs_to :fornecedor, class_name: "Usuario", foreign_key: "fornecedor_id"

  validates :status, inclusion: { in: ["pendente", "finalizado"] }
end
