class AddAdminFeedbackToQuotationResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :quotation_responses, :admin_feedback, :text
  end
end
