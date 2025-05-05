class ChangeQuotationResponseStatusDefaultToAguardandoResposta < ActiveRecord::Migration[8.0]
  def up
    change_column_default :quotation_responses, :status, from: "pendente", to: "aguardando_resposta"
    QuotationResponse.where(status: "pendente").update_all(status: "aguardando_resposta")
  end

  def down
    QuotationResponse.where(status: "aguardando_resposta").update_all(status: "pendente")
    change_column_default :quotation_responses, :status, from: "aguardando_resposta", to: "pendente"
  end
end
