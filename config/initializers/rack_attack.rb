class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Always allow localhost requests
  safelist('allow-localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  # Throttle all requests by IP (60 requests per minute)
  throttle('req/ip', limit: 60, period: 1.minute) do |req|
    if req.ip == '127.0.0.1' || req.ip == '::1'
      nil
    else
      req.ip
    end
  end

  # Return rate limit information in response headers
  self.throttled_response = lambda do |env|
    [ 429, {}, ["Rate limit exceeded. Please wait and try again later.\n"]]
  end
end
