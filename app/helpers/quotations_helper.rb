module QuotationsHelper
  def quotation_status_badge(status)
    case status
    when "aberta"
      content_tag(:span, "Aberta", class: "px-2 py-1 text-sm font-medium bg-blue-100 text-blue-800 rounded-full")
    when "resposta_recebida"
      content_tag(:span, "Resposta Recebida", class: "px-2 py-1 text-sm font-medium bg-indigo-100 text-indigo-800 rounded-full")
    when "visualizacao_liberada"
      content_tag(:span, "Visualização Liberada", class: "px-2 py-1 text-sm font-medium bg-green-100 text-green-800 rounded-full")
    when "respostas_encerradas"
      content_tag(:span, "Respostas Encerradas", class: "px-2 py-1 text-sm font-medium bg-yellow-100 text-yellow-800 rounded-full")
    when "expirada"
      content_tag(:span, "Expirada", class: "px-2 py-1 text-sm font-medium bg-gray-200 text-gray-700 rounded-full")
    when "concluida"
      content_tag(:span, "Concluída", class: "px-2 py-1 text-sm font-medium bg-emerald-100 text-emerald-800 rounded-full")
    when "arquivada"
      content_tag(:span, "Arquivada", class: "px-2 py-1 text-sm font-medium bg-gray-300 text-gray-800 rounded-full")
    else
      content_tag(:span, status.to_s.humanize, class: "px-2 py-1 text-sm font-medium bg-gray-100 text-gray-700 rounded-full")
    end
  end

  def quotation_action_buttons(quotation)
    buttons = []

    case quotation.status
    when "aberta"
      # Cliente pode editar e arquivar
      # buttons << link_to(
      #   "Editar Cotação",
      #   edit_quotation_path(quotation),
      #   class: "bg-indigo-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-indigo-700"
      # )
      # buttons << button_to(
      #   "Arquivar Cotação",
      #   arquivar_quotation_path(quotation),
      #   method: :patch,
      #   data: { confirm: "Tem certeza que deseja arquivar esta cotação?" },
      #   class: "bg-gray-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-gray-700"
      # )

    when "resposta_recebida"
      # Cliente só pode arquivar
      # buttons << button_to(
      #   "Arquivar Cotação",
      #   arquivar_quotation_path(quotation),
      #   method: :patch,
      #   data: { confirm: "Tem certeza que deseja arquivar esta cotação?" },
      #   class: "bg-gray-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-gray-700"
      # )

    when "visualizacao_liberada", "respostas_encerradas"
      # Cliente vê respostas e seleciona itens
      buttons << link_to(
        "Selecionar Itens",
        select_orders_quotation_path(quotation),
        class: "bg-green-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-green-700"
      )

    when "concluida"
      # Cliente acessa seus POs
      buttons << link_to(
        "Ver Meus Pedidos",
        purchase_orders_path,
        class: "bg-emerald-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-emerald-700"
      )

    else
      # expirada e arquivada: somente leitura, sem botões
    end

    return if buttons.empty?

    content_tag :div, class: "flex justify-center mb-6 space-x-4" do
      safe_join(buttons)
    end
  end

  def admin_quotation_action_buttons(quotation)
    buttons = []

    if %w[aberta resposta_recebida].include?(quotation.status)
      buttons << button_to(
        "Encerrar Respostas",
        encerrar_respostas_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Encerrar esta cotação para novas respostas?" },
        class: "bg-gray-600 text-white px-4 py-2 rounded shadow hover:bg-gray-700"
      )
    end

    if %w[aberta resposta_recebida].include?(quotation.status)
      buttons << button_to(
        "Liberar Visualização",
        liberar_visualizacao_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Liberar respostas aprovadas ao cliente?" },
        class: "bg-green-600 text-white px-4 py-2 rounded shadow hover:bg-green-700"
      )
    end

    if %w[aberta visualizacao_liberada resposta_recebida respostas_encerradas expirada concluida].include?(quotation.status)
      buttons << button_to(
        "Arquivar Cotação",
        arquivar_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Arquivar esta cotação?" },
        class: "bg-red-600 text-white px-4 py-2 rounded shadow hover:bg-red-700"
      )
    end

    return if buttons.empty?

    content_tag :div, safe_join(buttons), class: "flex space-x-4 mb-4"
  end

  def admin_quotation_response_action_buttons(response)
    return unless response.status == "documento_enviado"

    buttons = []

    if response.analysis_status == "aprovado"
      buttons << button_to(
        "Liberar para o cliente",
        liberar_visualizacao_admin_quotation_response_path(response),
        method: :patch,
        form: { data: { turbo_confirm: "Tem certeza que deseja liberar esta resposta para o cliente?" } },
        class: "block text-white bg-green-600 hover:bg-green-700 px-3 py-1 rounded-md text-sm"
      )
    elsif response.analysis_status == "pendente_de_analise"
      buttons << link_to(
        "Analisar documento",
        admin_quotation_response_path(response),
        class: "block text-white bg-yellow-500 hover:bg-yellow-600 px-3 py-1 rounded-md text-sm"
      )
    end

    return if buttons.empty?

    content_tag(:div, safe_join(buttons), class: "space-y-1")
  end

end
