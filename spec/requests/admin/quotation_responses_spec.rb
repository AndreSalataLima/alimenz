require 'rails_helper'

RSpec.describe "Admin::QuotationResponses", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/quotation_responses/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/quotation_responses/show"
      expect(response).to have_http_status(:success)
    end
  end
end
