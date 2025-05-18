class FixDefaultsInPurchaseOrderAndQuotationResponseStatus < ActiveRecord::Migration[8.0]
  def change
    change_column_default :purchase_orders, :status, from: "aberto", to: "aberta"
    change_column_default :quotation_responses, :status, from: "aguardando_resposta", to: "aberta"
    change_column_default :quotation_responses, :analysis_status, from: "aguardando_analise", to: "aberta"
  end
end
