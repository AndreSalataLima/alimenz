class AddResponseExpirationDateToQuotations < ActiveRecord::Migration[8.0]
  def up
    add_column :quotations, :response_expiration_date, :date

    # Força o ActiveRecord a recarregar os atributos com a nova coluna
    Quotation.reset_column_information

    Quotation.find_each do |q|
      # Aqui a gente já sabe que expiration_date nunca é nulo
      q.update_column(:response_expiration_date, q.expiration_date)
    end

    # Agora podemos colocar o NOT NULL com segurança
    change_column_null :quotations, :response_expiration_date, false
  end

  def down
    remove_column :quotations, :response_expiration_date
  end
end
