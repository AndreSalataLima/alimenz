class ChangeQuotationResponseAnalysisStatusDefaultToAguardandoAnalise < ActiveRecord::Migration[8.0]
  def up
    change_column_default :quotation_responses, :analysis_status, from: "pendente_de_analise", to: "aguardando_analise"
    QuotationResponse.where(analysis_status: "pendente_de_analise").update_all(analysis_status: "aguardando_analise")
  end

  def down
    QuotationResponse.where(analysis_status: "aguardando_analise").update_all(analysis_status: "pendente_de_analise")
    change_column_default :quotation_responses, :analysis_status, from: "aguardando_analise", to: "pendente_de_analise"
  end
end
