class ApplicationController < ActionController::Base
  include AnalyticsEvents

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # Crawlers are exempt: several (Bingbot, social preview bots) report an older
  # Chrome build in their user agent and would otherwise get the 406 page.
  allow_browser versions: :modern, unless: :crawler?

  # Search engines must never index the back office, even if a link leaks.
  before_action :noindex_admin_host

  layout :layout_for_request

  CRAWLER_PATTERN = /bot|crawl|spider|slurp|facebookexternalhit|whatsapp|preview|google-|anthropic|perplexity|chatgpt|cohere|lighthouse/i

  private

  def crawler?
    request.user_agent.to_s.match?(CRAWLER_PATTERN)
  end

  def noindex_admin_host
    response.set_header("X-Robots-Tag", "noindex, nofollow") if request.subdomain == "admin"
  end

  # Devise's own screens (sign in, password reset) only exist on the admin
  # subdomain, so they get the console's standalone auth layout.
  def layout_for_request
    devise_controller? ? "admin_auth" : "application"
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || admin_root_path
  end

  # The bare root on the admin subdomain is the marketing home page, so send a
  # signed-out admin back to the sign-in screen instead.
  def after_sign_out_path_for(_scope)
    new_admin_session_path
  end
end
