require "rails_helper"

RSpec.describe RateLimiter do
  include ActiveSupport::Testing::TimeHelpers

  let(:fake_request_store) { class_double(RequestStore).as_stubbed_const }
  let(:request_store) { instance_double(RequestStore) }
  let(:max_request_limit) { 2 }
  let(:rate_limiter) { RateLimiter.new(limit_requests_to: max_request_limit) }
  let(:ip_address) { "127.0.0.1" }

  before do
    allow(fake_request_store).to receive(:new).and_return(request_store)
  end

  describe "Checking if request is rate limited" do
    let(:other_ip_address) { "192.168.0.3" }

    before do
      allow(request_store).to receive(:request_count).with(ip_address: ip_address).and_return(request_count)
      allow(request_store).to receive(:request_count).with(ip_address: other_ip_address).and_return(0)
    end

    context "When Request limit has been reached for a client" do
      let(:request_count) { max_request_limit }

      specify "Request rate limited returns true for that client" do
        expect(rate_limiter.request_rate_limited?(ip_address: ip_address)).to be_truthy
      end

      specify "Request rate limited returns false for other clients" do
        expect(rate_limiter.request_rate_limited?(ip_address: other_ip_address)).to be_falsey
      end

      context "When a block is given" do
        specify do
          expect { |b| rate_limiter.request_rate_limited?(ip_address: ip_address, &b) }.to yield_control
        end
      end
    end

    context "When Request limit has not been reached for a client" do
      let(:request_count) { max_request_limit - 1 }

      specify "Request rate limited returns false for that client" do
        expect(rate_limiter.request_rate_limited?(ip_address: ip_address)).to be_falsey
      end
    end
  end

  describe "Recording requests" do
    before do
      allow(request_store).to receive(:record_request)
    end

    specify do
      rate_limiter.record_request(ip_address: ip_address)
      expect(request_store).to have_received(:record_request).with(ip_address: ip_address)
    end
  end

  describe "Returning the retry wait time" do
    let(:first_request_at) { Time.new(2017, 5, 1, 12, 0, 0) }

    before do
      allow(request_store).to receive(:first_request_at).with(ip_address: ip_address).and_return(first_request_at)
    end

    specify do
      travel_to(first_request_at) do
        expect(rate_limiter.retry_in(ip_address: ip_address)).to eq(RateLimiter::REQUEST_INTERVAL)
      end
    end
  end
end