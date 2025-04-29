require 'net/http'
require 'uri'
require 'json'

class UmamiTracker
  def self.track_event(event_name:, url:, referrer: nil, user_agent: nil, ip: nil, estado: nil, municipio: nil, colonia: nil)
    Rails.logger.info "Tracking event: #{event_name}, #{url}, #{referrer}, #{user_agent}, #{ip}"
    uri = URI.parse("https://voyager.albertson.codes/api/send")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json', 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0' })

    # build event data dynamically
    data = { ip: ip, user_agent: user_agent, url: url }
    data[:estado]    = estado    if estado.present?
    data[:municipio] = municipio if municipio.present?
    data[:colonia]   = colonia   if colonia.present?

    payload = {
      hostname: "ennuesta.casa",
      language: "en-US",
      referrer: "referrer",
      screen: "1920x1080",
      title: event_name,
      url: url,
      website: "cbdeacb8-3fdc-42a9-ad57-8fd4958b1a2b",
      name: event_name,
      data: data
    }

    request.body = { payload: payload, type: "event" }.to_json

    response = http.request(request)
    Rails.logger.info "Response: #{response.body}"
  end
end