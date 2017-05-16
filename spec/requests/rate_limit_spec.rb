require "rails_helper"

RSpec.describe "Rate limiting", type: :request do

  before do
    RequestStore.new(request_expiry: 10).reset!
  end

  context "When limit has been exceeded for a client" do
    before do
      (RateLimiter::MAX_REQUESTS_PER - 1).times do
        get "/home"
      end
    end

    specify "It blocks the clients request" do
      get "/home"
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  context "When limit has not been exceeded for a client" do
    specify "It allows the request" do
      get "/home"
      expect(response).to have_http_status(:ok)
    end
  end
end