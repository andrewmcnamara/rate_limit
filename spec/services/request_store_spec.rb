require "rails_helper"

RSpec.describe RequestStore do
  let(:fake_redis) { class_double(Redis).as_stubbed_const }
  let(:redis_client) { instance_double(Redis) }
  let(:request_expiry) {10}
  let(:request_store) {RequestStore.new(request_expiry: request_expiry)}

  before do
    allow(fake_redis).to receive(:new).and_return(redis_client)
  end

  describe "Recording requests" do
    before do
      allow(redis_client).to receive(:set)
    end

    specify "It stores the request for the given ip" do
      request_store.record_request(ip_address: "127.0.0.1")
      expect(redis_client).to have_received(:set).with(/127.0.0.1_/, anything, ex: request_expiry)
    end
  end

  describe "Counting requests" do
    let(:request_keys) { ["127.0.0.1_1494880338034"] }
    before do
      expect(redis_client).to receive(:keys).with("127.0.0.1*").and_return(request_keys)
    end

    specify "It returns a count of requests for the given ip" do
      expect(request_store.request_count(ip_address: "127.0.0.1")).to eq(request_keys.length)
    end
  end

  describe "Getting time of first request for an ip_address" do
    let(:request_keys) { ["127.0.0.1_1494880338034", "127.0.0.1_1494880373903"] }
    let(:first_request_timestamp) { "1494880338034" }
    before do
      expect(redis_client).to receive(:keys).with("127.0.0.1*").and_return(request_keys)
      expect(redis_client).to receive(:get).with("127.0.0.1_1494880338034").and_return(first_request_timestamp)
    end

    specify "It returns the time of the first request" do
      expect(request_store.first_request_at(ip_address: "127.0.0.1")).to eq(Time.at(first_request_timestamp.to_i))
    end
  end
end