class RequestStore
  def initialize(request_expiry:)
    @request_expiry = request_expiry
  end

  def record_request(ip_address:)
    timestamp = (Time.now.getutc.to_f * 1000).to_i

    store.set(store_key(ip_address: ip_address, timestamp: timestamp), timestamp, ex: @request_expiry)
  end

  def request_count(ip_address:)
    store.keys("#{ip_address}*").length
  end

  def first_request_at(ip_address:)
    first_request_key = store.keys("#{ip_address}*").first
    if first_request_key.present?
      Time.at(store.get(first_request_key).to_i)
    end
  end

  def reset!
    store.flushall
  end

  private

  def store_key(ip_address:, timestamp:)
    "#{ip_address}_#{timestamp}"
  end

  def store
    @request_store ||= Redis.new
  end
end