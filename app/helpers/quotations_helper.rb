module QuotationsHelper
  def quotation_status_badge(status)
    case status
    when "aberta"
      content_tag(:span, "Aberta", class: "px-2 py-1 text-sm font-medium bg-blue-100 text-blue-800 rounded-full")
    when "resposta_recebida"
      content_tag(:span, "Resposta Recebida", class: "px-2 py-1 text-sm font-medium bg-indigo-100 text-indigo-800 rounded-full")
    when "respostas_encerradas"
      content_tag(:span, "Respostas Encerradas", class: "px-2 py-1 text-sm font-medium bg-yellow-100 text-yellow-800 rounded-full")
    when "expirada"
      content_tag(:span, "Urgente", class: "px-2 py-1 text-sm font-medium bg-gray-200 text-gray-700 rounded-full")
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
      if quotation.quotation_responses
                  .where(status: "resposta_aprovada", analysis_status: "aprovado")
                  .exists?
        buttons << link_to(
          "Visualizar respostas",
          select_orders_quotation_path(quotation),
          class: "bg-green-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-green-700"
        )
      end

    when "respostas_encerradas", "concluida"
      # Cliente vê respostas e seleciona itens
      buttons << link_to(
        "Visualizar respostas",
        select_orders_quotation_path(quotation),
        class: "bg-green-600 text-white px-4 py-1 rounded-full font-medium shadow hover:bg-green-700"
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

    if %w[resposta_recebida].include?(quotation.status)
      buttons << button_to(
        "Encerrar Respostas",
        encerrar_respostas_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Encerrar esta cotação para novas respostas?" },
        class: "bg-gray-600 text-white px-4 py-2 rounded shadow hover:bg-gray-700"
      )

    end

    if %w[aberta resposta_recebida respostas_encerradas expirada concluida].include?(quotation.status)
      buttons << button_to(
        "Arquivar Cotação",
        arquivar_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Arquivar esta cotação? Isso irá arquivar todas as respostas de cotação e ordens de compra relacionadas" },
        class: "bg-red-600 text-white px-4 py-2 rounded shadow hover:bg-red-700"
      )
    end

    if quotation.status.in?(%w[resposta_recebida respostas_encerradas])
      buttons << button_to(
        "Concluir Cotação",
        concluir_admin_quotation_path(quotation),
        method: :patch,
        data: { turbo_confirm: "Marcar esta cotação como concluída?" },
        class: "bg-emerald-600 text-white px-4 py-2 rounded shadow hover:bg-emerald-700"
      )
    end

    return if buttons.empty?

    content_tag :div, safe_join(buttons), class: "flex space-x-4 mb-4"
  end

  def admin_quotation_response_action_buttons(response)
    buttons = []

    case response.analysis_status
    when "pendente_de_analise"
      # Botão para acessar a página de análise
      buttons << link_to(
        "Analisar documento",
        admin_quotation_response_path(response),
        class: "block text-white bg-yellow-500 hover:bg-yellow-600 px-3 py-1 rounded-md text-sm"
      )
    when "aprovado"
      # Nenhum botão adicional é necessário — aprovação já libera visualização
      buttons << content_tag(:span, "Aprovado e visível ao cliente",
        class: "block text-green-700 text-sm font-medium")
    end

    return if buttons.empty?

    content_tag(:div, safe_join(buttons), class: "space-y-1")
  end


end
