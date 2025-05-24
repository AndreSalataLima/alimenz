module PurchaseOrdersHelper
  # Badges de status
  def purchase_order_status_badge(status)
    case status
    when "aberta"
      content_tag(:span, "Aberta",
        class: "px-2 py-1 text-sm font-medium bg-blue-100 text-blue-800 rounded-full")
    when "confirmada"
      content_tag(:span, "Confirmada",
        class: "px-2 py-1 text-sm font-medium bg-green-100 text-green-800 rounded-full")
    when "arquivada"
      content_tag(:span, "Arquivada",
        class: "px-2 py-1 text-sm font-medium bg-gray-200 text-gray-700 rounded-full")
    else
      content_tag(:span, status.to_s.humanize,
        class: "px-2 py-1 text-sm font-medium bg-gray-100 text-gray-700 rounded-full")
    end
  end

  def admin_purchase_order_action_buttons(po)
    return unless po.aberta?

    buttons = []

    buttons << button_to("Confirmar",
      confirmar_admin_purchase_order_path(po),
      method: :patch,
      data: { turbo_confirm: "Confirmar este pedido?" },
      class: "bg-green-600 text-white px-3 py-1 rounded")

    buttons << button_to("Desconsiderar",
      desconsiderar_admin_purchase_order_path(po),
      method: :patch,
      data: { turbo_confirm: "Desconsiderar (arquivar) este pedido?" },
      class: "bg-red-600 text-white px-3 py-1 rounded")

    content_tag(:div, safe_join(buttons, " "), class: "flex space-x-2")
  end


  # Botão para o **cliente** arquivar pedidos confirmados
  def customer_purchase_order_action_buttons(po)
    return unless po.status == "Confirmada"

    button_to("Arquivar Pedido",
      arquivar_purchase_order_path(po),
      method: :patch,
      data: { confirm: "Tem certeza que deseja arquivar este pedido?" },
      class: "bg-gray-600 text-white px-4 py-1 rounded")
  end

  # Botões de ação para o **fornecedor**
  def supplier_purchase_order_action_buttons(po)
    content_tag(:div, class: "flex items-center space-x-2") do
        link_to("Visualizar PDF",
          secure_purchase_order_pdf_path(po.signed_id),
          target: "_blank",
          class: "text-green-600 hover:underline")
      end
  end
end
