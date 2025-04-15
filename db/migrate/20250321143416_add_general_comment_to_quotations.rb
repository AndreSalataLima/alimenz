class AddGeneralCommentToQuotations < ActiveRecord::Migration[8.0]
  def change
    add_column :quotations, :general_comment, :text
  end
end
