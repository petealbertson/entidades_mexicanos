module UmamiTrackable
  extend ActiveSupport::Concern

  included do
    after_action :track_event, only: [:index, :show]
  end

  private

  def track_event
    options = {
      event_name: "#{controller_name}##{action_name}",
      url: request.url,
      referrer: request.referrer,
      user_agent: request.user_agent,
      ip: request.remote_ip
    }
    options[:estado]    = "#{@estado.nombre} - #{@estado.clave}"    if defined?(@estado)    && @estado.present?
    options[:municipio] = "#{@municipio.nombre} - #{@municipio.clave}" if defined?(@municipio) && @municipio.present?
    options[:colonia]   = "#{@colonia.nombre} - #{@colonia.clave}"   if defined?(@colonia)   && @colonia.present?

    UmamiTracker.track_event(**options)
  end
end
