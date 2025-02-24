class FornecedorCategoria < ApplicationRecord
  belongs_to :fornecedor, class_name: "Usuario", foreign_key: "fornecedor_id"
  belongs_to :categoria

  after_create :incluir_fornecedor_em_cotacoes_abertas

  def incluir_fornecedor_em_cotacoes_abertas
    # Consideramos cotações cujas data_validade ainda não expiraram
    Cotacao.where("data_validade >= ?", Date.today).find_each do |cotacao|
      # Verifica se a cotação possui algum item cujo produto pertença à categoria atual
      if cotacao.itens_de_cotacao.joins(:produto)
             .where(produtos: { categoria_id: categoria_id }).exists?
        # Cria a resposta de cotação somente se ainda não existir para esse fornecedor
        unless cotacao.respostas_de_cotacao.exists?(fornecedor_id: fornecedor_id)
          cotacao.respostas_de_cotacao.create!(
            fornecedor: fornecedor,
            status: "pendente",
            data_validade: cotacao.data_validade
          )
        end
      end
    end
  end
  
end
