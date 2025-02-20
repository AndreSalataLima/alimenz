class ItemDeCotacao < ApplicationRecord
  self.table_name = "item_de_cotacaos"

  belongs_to :cotacao
  belongs_to :produto

  validates :quantidade, presence: true
  validates :unidade_selecionada, presence: true
end
