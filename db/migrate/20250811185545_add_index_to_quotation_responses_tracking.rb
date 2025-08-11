class AddIndexToQuotationResponsesTracking < ActiveRecord::Migration[8.0]
  def change
    add_index :quotation_responses, :signature_tracking_id, unique: true
  end
end
