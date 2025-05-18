module Suppliers::QuotationResponsesHelper
  # Badge de status do fornecedor
  def quotation_response_status_badge(response)
    case response.status
    when "aberta"
      badge("Aberta",      :blue)
    when "aguardando_assinatura"
      badge("Aguardando assinatura", :indigo)
    when "revisao_fornecedor"
      badge("Reenviar",  :yellow)
    when "documento_enviado"
      badge("Documento enviado", :purple)
    when "visualizacao_liberada"
      badge("Liberada p/ cliente", :green)
    when "arquivada"
      badge("Arquivada",    :gray)
    when "concluida"
      badge("Concluída",    :emerald)
    else
      badge((response.status || "sem status").humanize, :gray)
    end
  end

  # Botões de ação para o **fornecedor**
  def supplier_quotation_response_action_buttons(response)
    case response.status
    when "aberta"
      content_tag(:div, class: "flex items-center space-x-2") do
        link_to("Responder Cotação", edit_suppliers_quotation_response_path(response),
                class: "text-blue-600 hover:underline")
      end

    when "aguardando_assinatura", "revisao_fornecedor"
      content_tag(:div, class: "flex flex-col items-start space-y-2") do
        safe_join([
          link_to("Editar Resposta", edit_suppliers_quotation_response_path(response),
                  class: "text-blue-600 hover:underline"),
          link_to("Upload Documento Assinado", upload_document_suppliers_quotation_response_path(response),
                  class: "text-blue-600 hover:underline"),
          link_to("Pré-visualizar PDF", secure_pdf_suppliers_quotation_response_path(response.signed_id),
                  target: "_blank", class: "text-blue-600 hover:underline"),
          link_to("Assinar Digitalmente", "https://assinador.iti.br/assinatura/index.xhtml",
                  target: "_blank", class: "text-blue-600 hover:underline")
        ])
      end

    when "documento_enviado"
      content_tag(:div, class: "flex items-center space-x-2") do
        content_tag(:span, "Aguardando análise", class: "italic text-gray-600")
      end

    when "visualizacao_liberada"
      content_tag(:div, class: "flex items-center space-x-2") do
        link_to("Ver Resposta Liberada", secure_document_suppliers_quotation_response_path(response.signed_id),
                target: "_blank", class: "text-blue-600 hover:underline")
      end

    when "concluida"
      content_tag(:div, class: "flex items-center space-x-2") do
        link_to("Ver Resposta Final", secure_document_suppliers_quotation_response_path(response.signed_id),
                target: "_blank", class: "text-blue-600 hover:underline")
      end

    when "arquivada"
      content_tag(:div, class: "flex items-center space-x-2") do
        content_tag(:span, "Arquivada", class: "italic text-gray-500")
      end
    end
  end


  def badge(text, color)
    content_tag(:span, text,
      class: "px-2 py-1 text-sm font-medium bg-#{color}-100 text-#{color}-800 rounded-full")
  end

  # Botões de ação para o **admin**
  def admin_quotation_response_action_buttons(response)
    return unless response.status == "documento_enviado"

    if response.analysis_status == "pendente_de_analise"
      # botões inline de aprovar/reprovar
      safe_join([
        button_to("Aprovar", approve_admin_quotation_response_path(response),
                  method: :patch,
                  form: { data: { turbo_confirm: "Aprovar esta resposta?" } },
                  class: "bg-green-600 text-white px-3 py-1 rounded"),
        button_to("Reprovar", reject_admin_quotation_response_path(response),
                  method: :patch,
                  form: { data: { turbo_confirm: "Reprovar e enviar feedback?" } },
                  class: "bg-red-600 text-white px-3 py-1 rounded")
      ], " ")
    elsif response.analysis_status == "aprovado"
      # liberar visualização global
      button_to("Liberar", liberar_visualizacao_admin_quotation_response_path(response),
                method: :patch,
                data: { turbo_confirm: "Liberar para o cliente?" },
                class: "bg-blue-600 text-white px-3 py-1 rounded")
    end
  end


  # Badge de análise (admin)
  def quotation_response_analysis_badge(status)
    case status
    when "aberta"
      content_tag(:span, "Aguardando fornecedor", class: "px-2 py-1 text-sm font-medium bg-blue-100 text-blue-700 rounded-full")
    when "pendente_de_analise"
      content_tag(:span, "Pendente de Análise", class: "px-2 py-1 text-sm font-medium bg-yellow-100 text-yellow-700 rounded-full")
    when "aprovado"
      content_tag(:span, "Aprovado", class: "px-2 py-1 text-sm font-medium bg-green-100 text-green-700 rounded-full")
    when "reprovado"
      content_tag(:span, "Reprovado", class: "px-2 py-1 text-sm font-medium bg-red-100 text-red-700 rounded-full")
    else
      # Fallback para valores inválidos ou nulos
      label = status.present? ? status.humanize : "Status Indefinido"
      content_tag(:span, label, class: "px-2 py-1 text-sm font-medium bg-gray-100 text-gray-700 rounded-full")
    end
  end
end
