class AddTitleToQuotations < ActiveRecord::Migration[8.0]
  def change
    add_column :quotations, :title, :string
  end
end
