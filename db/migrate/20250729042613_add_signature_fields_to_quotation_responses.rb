class AddSignatureFieldsToQuotationResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :quotation_responses, :signed_at, :datetime
    add_column :quotation_responses, :signature_tracking_id, :string
    add_column :quotation_responses, :signed_ip, :string
  end
end
