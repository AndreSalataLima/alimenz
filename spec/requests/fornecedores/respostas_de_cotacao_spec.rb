require 'rails_helper'

RSpec.describe "Fornecedores::RespostasDeCotacoes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/fornecedores/respostas_de_cotacao/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/fornecedores/respostas_de_cotacao/show"
      expect(response).to have_http_status(:success)
    end
  end

end
