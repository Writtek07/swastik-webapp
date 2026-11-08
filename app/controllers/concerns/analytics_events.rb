# Server-confirmed Google Analytics events.
#
# `track_event` queues an event in the flash, so it survives a redirect and is
# sent by the browser on the page that follows (shared/_analytics_events,
# app/javascript/lib/analytics.js). Use it for outcomes only the server knows, such
# as an enquiry that actually saved, rather than tracking button presses.
#
# Never pass personal data (names, emails, phone numbers): Google Analytics
# policy forbids it.
module AnalyticsEvents
  extend ActiveSupport::Concern

  FLASH_KEY = :analytics_events

  private

  def track_event(name, **params)
    flash[FLASH_KEY] = Array(flash[FLASH_KEY]) + [ { "name" => name.to_s, "params" => params.compact.stringify_keys } ]
  end
end
