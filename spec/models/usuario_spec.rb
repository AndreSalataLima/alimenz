require 'rails_helper'

RSpec.describe Usuario, type: :model do
  subject {
    described_class.new(
      nome: "Teste",
      email: "teste@example.com",
      papel: "cliente",
      password: "password",
      password_confirmation: "password"
    )
  }

  it "é válido com atributos válidos" do
    expect(subject).to be_valid
  end

  it "não é válido sem nome" do
    subject.nome = nil
    expect(subject).not_to be_valid
  end

  it "não é válido com papel fora dos permitidos" do
    subject.papel = "invalido"
    expect(subject).not_to be_valid
  end

  it "possui scope para clientes" do
    described_class.create!(nome: "Cliente", email: "cliente@example.com", papel: "cliente", password: "password", password_confirmation: "password")
    expect(Usuario.where(papel: "cliente").count).to eq(1)
  end
end
