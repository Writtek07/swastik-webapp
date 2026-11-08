# The daily price sheet.
#
# One row per product family per day. The index renders the whole sheet for a
# date as a single form so an admin can fill in every family and save once,
# with the price history underneath. `create` upserts the rows that changed.
class Admin::DailyPricesController < Admin::BaseController
  HISTORY_WINDOWS = [ 7, 30, 90 ].freeze

  def index
    @date = selected_date
    load_sheet

    @history_days = HISTORY_WINDOWS.include?(params[:days].to_i) ? params[:days].to_i : 30
    @history_product = @products.find { |product| product.id.to_s == params[:product_id].to_s }
    history = DailyPrice.with_previous_price
                        .where(priced_on: (Date.current - (@history_days - 1))..Date.current)
                        .then { |scope| @history_product ? scope.where(product: @history_product) : scope }
                        .recent
                        .includes(:product, :admin)
    @pagy, @history = pagy(history)
    # Grouping happens per page, so a day that straddles a page break simply
    # repeats its heading at the top of the next page.
    @history_by_day = @history.group_by(&:priced_on)
  end

  def create
    @date = selected_date
    saved = []
    failed = []

    DailyPrice.transaction do
      submitted_prices.each do |product_id, attributes|
        next if attributes[:price].blank?

        price = DailyPrice.find_or_initialize_by(product_id: product_id, priced_on: @date)
        # `admin` is only assigned on the first save so the sheet keeps showing who
        # originally created the day's price.
        price.admin ||= current_admin
        price.assign_attributes(attributes)
        next unless price.changed?

        price.save ? saved << price : failed << price
      end
    end

    if failed.any?
      details = failed.map { |price| "#{price.product.title}: #{price.errors.full_messages.to_sentence}" }
      redirect_to admin_daily_prices_path(priced_on: @date), alert: "Some prices weren't saved. #{details.join('; ')}"
    elsif saved.empty?
      redirect_to admin_daily_prices_path(priced_on: @date), alert: "Nothing changed — enter or edit at least one price before saving."
    else
      redirect_to admin_daily_prices_path(priced_on: @date),
                  notice: "Saved #{saved.size} #{'price'.pluralize(saved.size)} for #{@date.strftime('%-d %b %Y')}."
    end
  end

  private

  def load_sheet
    @products = Product.ordered.to_a
    @prices = DailyPrice.for_date(@date).includes(:admin).index_by(&:product_id)
    @previous = DailyPrice.latest_before(@date)
  end

  # Defaults to today; future dates are clamped because a price can't be set for
  # a day that hasn't happened yet.
  def selected_date
    date = Date.parse(params[:priced_on].to_s)
    [ date, Date.current ].min
  rescue Date::Error, TypeError
    Date.current
  end

  # The sheet posts `prices[<product_id>][price|notes]`; keep only real
  # products and the editable attributes.
  def submitted_prices
    raw = params.fetch(:prices, {})
    return {} unless raw.respond_to?(:to_unsafe_h)

    raw.to_unsafe_h.slice(*Product.pluck(:id).map(&:to_s)).transform_values do |attributes|
      next {} unless attributes.is_a?(Hash)

      attributes.slice("price", "notes").symbolize_keys.tap do |attrs|
        attrs[:notes] = attrs[:notes].presence if attrs.key?(:notes)
      end
    end
  end
end
