class Cotacao < ApplicationRecord
  self.table_name = "cotacaos"

  belongs_to :cliente, class_name: "Usuario", foreign_key: "cliente_id"
  has_many :itens_de_cotacao, class_name: "ItemDeCotacao", dependent: :destroy
  has_many :respostas_de_cotacao, class_name: "RespostaDeCotacao", dependent: :destroy

  accepts_nested_attributes_for :itens_de_cotacao, allow_destroy: true,
  reject_if: proc { |attributes| attributes['quantidade'].to_f <= 0 || attributes['unidade_selecionada'].blank? }
  # Após criar a cotação, gerar automaticamente as respostas
  after_create :gerar_respostas_de_cotacao

  attribute :status, :string, default: 'pendente'

  
  private

  def gerar_respostas_de_cotacao
    # Coletar os IDs das categorias dos produtos incluídos na cotação
    categorias_ids = itens_de_cotacao.map { |item| item.produto.categoria_id }.uniq

    # Filtrar fornecedores que atendam a essas categorias (usando a associação FornecedorCategoria)
    fornecedores = Usuario.joins(:fornecedor_categorias)
                          .where(papel: 'fornecedor', fornecedor_categorias: { categoria_id: categorias_ids })
                          .distinct

    # Para cada fornecedor qualificado, criar uma resposta com status "pendente"
    fornecedores.each do |fornecedor|
      RespostaDeCotacao.create!(
        cotacao: self,
        fornecedor: fornecedor,
        status: "pendente",
        data_validade: self.data_validade
      )
    end
  end
end
