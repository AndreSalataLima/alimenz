class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin

  def index
    @cotacoes_abertas = Quotation.where(status: :aberta)
    @cotacoes_proximas_do_vencimento = Quotation
      .where(status: [ :aberta, :resposta_recebida, :resposta_aprovada, :respostas_encerradas ])
      .where(expiration_date: Date.today..3.days.from_now)

    @cotacoes_arquivadas_7d = Quotation.where(status: :arquivada)
                                       .where("updated_at >= ?", 7.days.ago)

    @resps_aprovadas_nao_visiveis = QuotationResponse.where(status: :documento_enviado, analysis_status: :aprovado)

    @resps_pendentes_analise = QuotationResponse.where(analysis_status: :pendente_de_analise)

    @ordens_abertas = PurchaseOrder.where(status: :aberta)
  end


  private

  def verify_admin
    unless current_user && current_user.role == "admin"
      redirect_to root_path, alert: "Access denied."
    end
  end
end
