class RateLimiter
  MAX_REQUESTS_PER = 100
  REQUEST_INTERVAL = 60 * 60

  def initialize(limit_requests_to: MAX_REQUESTS_PER, request_interval: REQUEST_INTERVAL)
    @limit_requests_to = limit_requests_to
    @request_interval = request_interval
  end

  def request_rate_limited?(ip_address:)
    rate_limited = store.request_count(ip_address: ip_address) >= @limit_requests_to

    yield if rate_limited && block_given?

    rate_limited
  end

  def record_request(ip_address:)
    store.record_request(ip_address: ip_address)
  end

  def retry_in(ip_address:)
    next_request_permitted = store.first_request_at(ip_address: ip_address) + @request_interval.seconds
    (next_request_permitted - Time.zone.now).to_i
  end

  private
  def store
    @request_store ||= RequestStore.new(request_expiry: REQUEST_INTERVAL)
  end
end
