class Quotation < ApplicationRecord
  validates :title, presence: true
  validates :expiration_date, :response_expiration_date, presence: true
  validate :expiration_dates_must_be_future, on: :create



  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  has_many :quotation_items, dependent: :destroy
  has_many :quotation_responses, dependent: :destroy
  has_many :purchase_orders, dependent: :destroy

  accepts_nested_attributes_for :quotation_items, allow_destroy: true,
  reject_if: proc { |attributes| attributes["quantity"].to_f <= 0 || attributes["selected_unit"].blank? }

  before_create :capture_customer_snapshot
  after_create :generate_quotation_responses

  # attribute :status, :string, default: "aberta"

  after_commit :notify_ong_async, on: :create

  enum :status, {
    aberta: "aberta",
    resposta_recebida: "resposta_recebida",
    respostas_encerradas: "respostas_encerradas",
    expirada: "expirada",
    concluida: "concluida",
    arquivada: "arquivada"
  }

  def self.expire_expired_quotations
    where(status: [ :aberta, :resposta_recebida ])
      .where("expiration_date < ?", Date.today)
      .find_each do |quotation|
      quotation.transaction do
        quotation.update!(status: "expirada")
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
        end
      end
    end
  end


  private

  def generate_quotation_responses
    category_ids = quotation_items.map { |item| item.product.category_id }.uniq
    city_id      = customer.city_id

    if city_id.blank?
      Rails.logger.warn("[Quotation##{id}] Cliente sem city_id; nenhuma resposta será gerada.")
      return
    end

    suppliers = User
                  .joins(:supplier_categories, :supplier_served_cities)
                  .where(
                    role: "supplier",
                    supplier_categories: { category_id: category_ids },
                    supplier_served_cities: { city_id: city_id }
                  )
                  .where.not(id: customer.blocked_supplier_ids)
                  .distinct

    suppliers.each do |supplier|
      begin
        QuotationResponse.create!(
          quotation: self,
          supplier: supplier,
          status: "aberta",
          analysis_status: "analise_aberta",
          expiration_date: response_expiration_date
        )
      rescue => e
        Rails.logger.error "Erro ao criar QuotationResponse para supplier #{supplier.id}: #{e.message}"
        raise
      end
    end
  end


  def capture_customer_snapshot
    self.customer_snapshot = customer.slice(
      "name", "email", "address", "phone", "cnpj", "responsible", "trade_name"
    )
  end

  def expiration_dates_must_be_future
    if expiration_date && expiration_date <= Date.today
      errors.add(:expiration_date, "deve ser futura")
    end
    if response_expiration_date && response_expiration_date <= Date.today
      errors.add(:response_expiration_date, "deve ser futura")
    end
  end

  def notify_ong_async
    QuotationCreatedNotificationJob.perform_later(id)
  end
end
