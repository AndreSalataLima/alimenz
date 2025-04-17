module ApplicationHelper
  include Pagy::Frontend

  def display_name(product)
    return product.generic_name unless current_user&.role == "cliente"
    custom = CustomizedProduct.find_by(customer_id: current_user.id, product_id: product.id)
    custom ? custom.custom_name : product.generic_name
  end

  def real_currency(value)
    "R$ #{number_with_precision(value, precision: 2, delimiter: ".", separator: ",")}"
  end

  def pagy_tailwind_nav(pagy)
    html = +''

    link_classes = 'px-3 py-1 mx-1 rounded border border-gray-300 hover:bg-gray-100 transition text-sm'
    active_classes = 'bg-[#615F4A] text-white border-[#615F4A]'

    pagy.series.each do |item|
      case item
      when Integer
        if item == pagy.page
          html << %(<span class="#{link_classes} #{active_classes}">#{item}</span>)
        else
          # monta o link manualmente
          html << %(<a href="?page=#{item}" class="#{link_classes}">#{item}</a>)
        end
      when String
        html << %(<span class="#{link_classes} cursor-default text-gray-400">#{item}</span>)
      when :gap
        html << %(<span class="#{link_classes} cursor-default text-gray-400">…</span>)
      when :prev
        html << %(<a href="#{pagy_url_for(:prev, pagy)}" class="#{link_classes}">&laquo;</a>) if pagy.prev
      when :next
        html << %(<a href="#{pagy_url_for(:next, pagy)}" class="#{link_classes}">&raquo;</a>) if pagy.next
      end
    end

    %(<nav class="flex justify-center mt-6">#{html}</nav>).html_safe
  end



end
