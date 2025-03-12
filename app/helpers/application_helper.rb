module ApplicationHelper
  def display_name(product)
    return product.generic_name unless current_user&.role == "cliente"
    custom = CustomizedProduct.find_by(customer_id: current_user.id, product_id: product.id)
    custom ? custom.custom_name : product.generic_name
  end
end
