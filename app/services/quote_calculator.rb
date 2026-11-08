# Prices a public "Get your quote" request: one size of a gauge-priced product
# at a given quantity.
#
#   rate     = basic price + gauge difference   (both ₹/MT)
#   amount   = rate × quantity
#   taxable  = amount + loading charges   (loading is added once per quote)
#   total    = taxable + GST % of taxable
#
# The basic price is the product's latest daily price on or before the quote
# date; the gauge difference is the size's price in the gauge session covering
# that date; loading and GST come from Setting. Anything missing makes the
# product/size unquotable rather than quietly pricing it at zero.
class QuoteCalculator
  class Error < StandardError; end

  MAX_QUANTITY = 10_000

  Quote = Data.define(:number, :quoted_on, :product, :size, :quantity, :basic_price, :basic_priced_on,
                      :guage_diff, :guage_session, :rate, :amount, :loading_charges, :taxable,
                      :gst_percent, :gst, :total)

  # { product => [sizes] } for every product/size a quote can be priced for
  # today: flagged products with a daily price and a gauge price for the size.
  def self.quotable(on: Date.current)
    session = GuageSession.covering(on).first or return {}

    products = Product.with_guage_price.ordered.to_a
    priced = DailyPrice.where(product: products, priced_on: ..on).distinct.pluck(:product_id).to_set
    sizes = session.guage_prices.where(product: products).pluck(:product_id, :size)
                   .group_by(&:first).transform_values { |rows| rows.map(&:last) }

    products.each_with_object({}) do |product, quotable|
      next unless priced.include?(product.id)

      available = product.sizes & sizes.fetch(product.id, [])
      quotable[product] = available if available.any?
    end
  end

  def initialize(product_id:, size:, quantity:, on: Date.current)
    @product_id = product_id
    @size = size.to_s
    @quantity = quantity
    @on = on
  end

  def call
    product = Product.with_guage_price.find_by(id: @product_id) or raise Error, "Choose a product from the list."
    raise Error, "Choose one of the listed sizes for #{product.title}." unless product.sizes.include?(@size)

    quantity = parse_quantity
    session = GuageSession.covering(@on).first or raise Error, "Gauge prices aren't published at the moment."
    guage = session.guage_prices.find_by(product: product, size: @size) or
      raise Error, "#{product.title} #{@size} isn't priced yet — please send an enquiry instead."
    basic = product.daily_prices.where(priced_on: ..@on).order(priced_on: :desc).first or
      raise Error, "Today's basic price for #{product.title} isn't published yet."

    setting = Setting.current
    raise Error, "Quotes are unavailable right now. Please contact the sales desk." if setting.gst_percent.nil?

    rate = basic.price + guage.price
    amount = (rate * quantity).round(2)
    loading = setting.loading_charges || 0
    taxable = amount + loading
    gst = (taxable * setting.gst_percent / 100).round(2)

    Quote.new(number: "Q-#{@on.strftime('%Y%m%d')}-#{SecureRandom.alphanumeric(5).upcase}", quoted_on: @on,
              product:, size: @size, quantity:, basic_price: basic.price, basic_priced_on: basic.priced_on,
              guage_diff: guage.price, guage_session: session, rate:, amount:, loading_charges: loading,
              taxable:, gst_percent: setting.gst_percent, gst:, total: taxable + gst)
  end

  private

  def parse_quantity
    quantity = BigDecimal(@quantity.to_s.strip)
    raise ArgumentError unless quantity.positive? && quantity <= MAX_QUANTITY

    quantity.round(3)
  rescue ArgumentError, TypeError
    raise Error, "Enter a quantity between 0.001 and #{MAX_QUANTITY} MT."
  end
end
