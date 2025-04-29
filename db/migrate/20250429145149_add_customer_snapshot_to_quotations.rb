class AddCustomerSnapshotToQuotations < ActiveRecord::Migration[8.0]
  def change
    add_column :quotations, :customer_snapshot, :jsonb
  end
end
