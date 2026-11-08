# Google Analytics hooks for views. See app/javascript/lib/analytics.js for the
# client side and AnalyticsEvents for events queued by controllers.
module AnalyticsHelper
  # Queues an event for the page being rendered (e.g. view_item on a product
  # page). Sent once by the browser when the page loads.
  def analytics_event(name, **params)
    (@analytics_events ||= []) << { "name" => name.to_s, "params" => params.compact.stringify_keys }
    nil
  end

  # This page's events plus any a controller queued before redirecting here.
  def pending_analytics_events
    Array(flash[AnalyticsEvents::FLASH_KEY]) + Array(@analytics_events)
  end

  # GA4 item shape for a product, shared by every ecommerce-style event.
  def analytics_item(product, **extra)
    { item_id: product.slug, item_name: product.title, item_category: product.category, **extra }.compact
  end

  # data-* for a product card or link, read by select_item tracking.
  def analytics_item_data(product)
    { analytics_item_name: product.title, analytics_item_category: product.category }
  end
end
