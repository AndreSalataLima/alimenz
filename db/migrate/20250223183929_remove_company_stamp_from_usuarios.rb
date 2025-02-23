class RemoveCompanyStampFromUsuarios < ActiveRecord::Migration[8.0]
  def change
    remove_column :usuarios, :company_stamp, :text
  end
end
