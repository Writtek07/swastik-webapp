# The gauge price sheet.
#
# Gauge prices are set once per session (normally a year) for every size of
# every product flagged `has_guage_price`. The index shows the sheet for one
# session, editable only while that session is in progress; `create` upserts
# the submitted rows into the session in progress. A size priced once can be
# updated but never duplicated (GuagePrice is unique per session/product/size).
class Admin::GuagePricesController < Admin::BaseController
  def index
    @guage_sessions = GuageSession.chronological.includes(:created_by).to_a
    @guage_session = @guage_sessions.find { |guage_session| guage_session.id.to_s == params[:session_id].to_s } ||
               @guage_sessions.find(&:in_progress?)
    @products = Product.with_guage_price.ordered.to_a
    @prices = if @guage_session
      @guage_session.guage_prices.includes(:entered_by, :updated_by).index_by { |price| [ price.product_id, price.size ] }
    else
      {}
    end
  end

  def create
    guage_session = GuageSession.current
    unless guage_session
      return redirect_to admin_guage_prices_path, alert: "There's no gauge session in progress. An owner needs to open one first."
    end

    saved = []
    failed = []

    GuagePrice.transaction do
      submitted_entries.each do |entry|
        # Blank inputs are skipped rather than clearing a saved price: within a
        # session a price can be changed but not removed.
        next if entry[:price].blank?

        price = guage_session.guage_prices.find_or_initialize_by(product_id: entry[:product_id], size: entry[:size])
        price.entered_by ||= current_admin
        price.price = entry[:price]
        next unless price.changed?

        price.updated_by = current_admin
        price.save ? saved << price : failed << price
      end
      raise ActiveRecord::Rollback if failed.any?
    end

    if failed.any?
      details = failed.map { |price| "#{price.product&.title} #{price.size}: #{price.errors.full_messages.to_sentence}" }
      redirect_to admin_guage_prices_path, alert: "Nothing was saved. #{details.join('; ')}"
    elsif saved.empty?
      redirect_to admin_guage_prices_path, alert: "Nothing changed — enter or edit at least one gauge price before saving."
    else
      redirect_to admin_guage_prices_path,
                  notice: "Saved #{saved.size} gauge #{'price'.pluralize(saved.size)} for the #{guage_session.label} session."
    end
  end

  private

  # The sheet posts `entries[<n>][product_id|size|price]`, one per size row.
  # Sizes are free text ("3/4 in", "100 × 50"), so they travel as values rather
  # than as parameter keys.
  def submitted_entries
    raw = params.fetch(:entries, {})
    return [] unless raw.respond_to?(:to_unsafe_h)

    raw.to_unsafe_h.values.filter_map do |entry|
      next unless entry.is_a?(Hash)

      { product_id: entry["product_id"].to_i, size: entry["size"].to_s, price: entry["price"].to_s.strip }
    end
  end
end
