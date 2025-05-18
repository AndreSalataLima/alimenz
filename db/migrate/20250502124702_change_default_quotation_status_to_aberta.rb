class ChangeDefaultQuotationStatusToAberta < ActiveRecord::Migration[8.0]
  def up
    change_column_default :quotations, :status, from: "pendente", to: "aberta"
  end

  def down
    change_column_default :quotations, :status, from: "aberta", to: "pendente"
  end
end
