class AddPaidInFullToCommissions < ActiveRecord::Migration[8.0]
  def change
    add_column :commissions, :paid_in_full, :boolean, default: false, null: false
  end
end
