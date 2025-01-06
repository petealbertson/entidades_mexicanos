class ApplicationController < ActionController::API
  before_action :log_request

  private

  def log_request
    Rails.logger.info "API Request: #{request.method} #{request.path} from IP: #{request.ip}"
  end
end
