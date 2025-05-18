class Quotation < ApplicationRecord
  validates :expiration_date, presence: true
  validate :expiration_date_must_be_future


  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  has_many :quotation_items, dependent: :destroy
  has_many :quotation_responses, dependent: :destroy
  has_many :purchase_orders, dependent: :destroy

  accepts_nested_attributes_for :quotation_items, allow_destroy: true,
  reject_if: proc { |attributes| attributes["quantity"].to_f <= 0 || attributes["selected_unit"].blank? }

  before_create :capture_customer_snapshot
  after_create :generate_quotation_responses

  # attribute :status, :string, default: "aberta"

  enum :status, {
    aberta: 'aberta',
    resposta_recebida: 'resposta_recebida',
    visualizacao_liberada: 'visualizacao_liberada',
    respostas_encerradas: 'respostas_encerradas',
    expirada: 'expirada',
    concluida: 'concluida',
    arquivada: 'arquivada'
  }

  def self.expire_expired_quotations
    where(status: [:aberta, :resposta_recebida, :visualizacao_liberada, :respostas_encerradas])
      .where("expiration_date < ?", Date.today)
      .find_each do |quotation|

      quotation.transaction do
        quotation.update!(status: "expirada")

        quotation.quotation_responses.each do |response|
          case response.status
          when "aberta", "aguardando_assinatura", "revisao_fornecedor"
            response.update!(status: "arquivada")
          when "documento_enviado", "visualizacao_liberada"
            response.update!(status: "concluida")
          end
        end
      end
    end
  end


  def marcar_como_resposta_recebida!
    update!(status: :resposta_recebida) if aberta?
  end

  def encerrar_para_novas_respostas!
    transaction do
      update!(status: "respostas_encerradas")

      quotation_responses.each do |response|
        case response.status
        when "aberta", "aguardando_assinatura", "revisao_fornecedor"
          response.update!(status: "arquivada")
        when "documento_enviado"
          if response.analysis_status == "aprovado"
            response.update!(status: "visualizacao_liberada")
          else
            response.update!(status: "arquivada")
          end
        end
      end
    end
  end


  private

  def generate_quotation_responses
    category_ids = quotation_items.map { |item| item.product.category_id }.uniq

    suppliers = User.joins(:supplier_categories)
                    .where(role: "supplier", supplier_categories: { category_id: category_ids })
                    .where.not(id: customer.blocked_supplier_ids)
                    .distinct

    suppliers.each do |supplier|
      begin
        QuotationResponse.create!(
          quotation: self,
          supplier: supplier,
          status: "aberta",
          analysis_status: "aberta",
          expiration_date: expiration_date
        )
      rescue => e
        Rails.logger.error "Erro ao criar QuotationResponse para supplier #{supplier.id}: #{e.message}"
        raise
      end
    end
  end


  def capture_customer_snapshot
    self.customer_snapshot = customer.slice(
      'name', 'email', 'address', 'phone', 'cnpj', 'responsible', 'trade_name'
    )
  end

  def expiration_date_must_be_future
    return if expiration_date.blank?

    if expiration_date <= Date.today && new_record?
      errors.add(:expiration_date, "deve ser uma data futura")
    end
  end


end
