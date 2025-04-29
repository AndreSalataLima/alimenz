class AddSupplierSnapshotToQuotationResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :quotation_responses, :supplier_snapshot, :jsonb
  end
end
