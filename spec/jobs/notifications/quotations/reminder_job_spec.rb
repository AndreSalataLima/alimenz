require "rails_helper"

RSpec.describe Notifications::Quotations::ReminderJob, type: :job do
  let(:state) { State.create!(name: "Rio de Janeiro", code: "RJ") }
  let(:city) { City.create!(name: "Rio de Janeiro", state: state) }
  let(:customer) do
    User.create!(
      email: "cliente@example.com",
      password: "password123",
      name: "Cliente",
      role: "customer",
      cnpj: "00000000000000",
      responsible: "Cliente Resp",
      address: "Rua 3",
      phone: "+5521999999999",
      city: city
    )
  end
  let(:quotation) do
    Quotation.create!(
      title: "Cotação para testes",
      expiration_date: 7.days.from_now.to_date,
      response_expiration_date: 5.days.from_now.to_date,
      customer: customer
    )
  end

  describe "#perform" do
    it "executa o serviço de lembrete" do
      service_instance = instance_double(Notifications::Quotations::ReminderService)

      expect(Notifications::Quotations::ReminderService).to receive(:new).with(record: quotation).and_return(service_instance)
      expect(service_instance).to receive(:deliver).with("two_days_after_creation")

      described_class.perform_now("Quotation", quotation.id, "two_days_after_creation")
    end

    it "registra aviso quando o registro não existe" do
      expect(Rails.logger).to receive(:warn).with(include("Registro Quotation#9999 não encontrado")).and_call_original

      described_class.perform_now("Quotation", 9999, "two_days_after_creation")
    end

    it "registra erro para tipos desconhecidos" do
      expect(Rails.logger).to receive(:error).with(include("Tipo de registro desconhecido Inexistente"))

      described_class.perform_now("Inexistente", quotation.id, "two_days_after_creation")
    end
  end
end
