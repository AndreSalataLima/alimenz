class AddProductCommentToQuotationItems < ActiveRecord::Migration[8.0]
  def change
    add_column :quotation_items, :product_comment, :string
  end
end
