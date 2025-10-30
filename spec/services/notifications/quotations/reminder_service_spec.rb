require "rails_helper"

RSpec.describe Notifications::Quotations::ReminderService do
  let(:state) { State.create!(name: "Sao Paulo", code: "SP") }
  let(:city) { City.create!(name: "Sao Paulo", state: state) }
  let(:customer) do
    User.create!(
      email: "customer@example.com",
      password: "password123",
      name: "Cliente",
      role: "customer",
      cnpj: "12345678901234",
      responsible: "Responsavel",
      address: "Rua 1",
      phone: "+5511999999999",
      city: city
    )
  end
  let(:supplier) do
    User.create!(
      email: "supplier@example.com",
      password: "password123",
      name: "Fornecedor",
      role: "supplier",
      cnpj: "98765432101234",
      responsible: "Fornecedor Resp",
      address: "Rua 2",
      phone: "+5511988888888",
      city: city
    )
  end
  let(:quotation) do
    Quotation.create!(
      title: "Cotação Teste",
      expiration_date: 5.days.from_now.to_date,
      response_expiration_date: 3.days.from_now.to_date,
      customer: customer
    )
  end

  let!(:quotation_response) do
    QuotationResponse.create!(
      quotation: quotation,
      supplier: supplier,
      status: :aberta,
      analysis_status: :analise_aberta,
      expiration_date: 4.days.from_now.to_date
    )
  end

  let(:email_provider) { instance_double(Notifications::Providers::EmailProvider) }
  let(:whatsapp_provider) { instance_double(Notifications::Providers::WhatsappProvider) }

  describe "#deliver" do
    it "envia notificações para todos os fornecedores da cotação" do
      service = described_class.new(record: quotation, email_provider: email_provider, whatsapp_provider: whatsapp_provider)

      expect(email_provider).to receive(:deliver).with(hash_including(recipient: "supplier@example.com", subject: include("Cotação Teste"))).once
      expect(whatsapp_provider).to receive(:deliver).with(hash_including(phone: "+5511988888888", message: include("Cotação Teste"))).once

      service.deliver(:two_days_after_creation)
    end

    it "envia notificações diretamente para o fornecedor da resposta" do
      service = described_class.new(record: quotation_response, email_provider: email_provider, whatsapp_provider: whatsapp_provider)

      expect(email_provider).to receive(:deliver).with(hash_including(recipient: "supplier@example.com", subject: include("Cotação Teste"))).once
      expect(whatsapp_provider).to receive(:deliver).with(hash_including(phone: "+5511988888888", message: include("Cotação Teste"))).once

      service.deliver("on_expiration_day")
    end

    it "não envia quando não há destinatários" do
      quotation.quotation_responses.delete_all
      service = described_class.new(record: quotation, email_provider: email_provider, whatsapp_provider: whatsapp_provider)

      expect(email_provider).not_to receive(:deliver)
      expect(whatsapp_provider).not_to receive(:deliver)

      service.deliver(:one_day_before_expiration)
    end

    it "levanta erro para gatilho desconhecido" do
      service = described_class.new(record: quotation, email_provider: email_provider, whatsapp_provider: whatsapp_provider)

      expect { service.deliver(:unknown) }.to raise_error(ArgumentError, /gatilho desconhecido/)
    end
  end
end
