class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :rate_limit_request

  protected

  def rate_limit_request
    ip_address = request.remote_ip

    rate_limiter.record_request(ip_address: ip_address)

    rate_limiter.request_rate_limited?(ip_address: ip_address) do
      retry_in = rate_limiter.retry_in(ip_address: ip_address)
      render plain: "Rate limit exceeded. Try again in #{retry_in} seconds", status: :too_many_requests
    end
  end

  def rate_limiter
    @rate_limiter ||= RateLimiter.new
  end
end
