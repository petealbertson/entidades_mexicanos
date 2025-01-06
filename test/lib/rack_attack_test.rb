require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    # Ensure we're using memory store for cache in tests
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.clear
    @remote_addr = "192.168.1.1"
    # Reset all Rack::Attack cache keys
    Rack::Attack.reset!
  end

  teardown do
  end

  def remote_headers
    { 
      "REMOTE_ADDR" => @remote_addr
    }
  end

  test "allows requests under rate limit" do
    5.times do |i|
      get "/api/v1/estados", headers: remote_headers
      assert_response :success, "Request #{i} failed but should have succeeded. Status: #{response.status}"
    end
  end

  test "throttles requests over rate limit" do
    61.times do |i|
      get "/api/v1/estados", headers: remote_headers
      
      if i < 60
        assert_response :success, "Request #{i} failed but should have succeeded. Status: #{response.status}"
      else
        assert_response 429, "Request #{i} should have been throttled but wasn't"
        assert_equal "Rate limit exceeded. Please wait and try again later.\n", response.body
      end
    end
  end

  test "never throttles localhost requests" do
    # Test IPv4 localhost
    10.times do |i|
      get "/api/v1/estados", headers: { "REMOTE_ADDR" => "127.0.0.1" }
      assert_response :success, "IPv4 localhost request #{i} should always succeed"
    end
  end
end
