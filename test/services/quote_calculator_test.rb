require "test_helper"

class QuoteCalculatorTest < ActiveSupport::TestCase
  setup do
    @tmt = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars", position: 1,
                           sizes: [ "8 mm", "10 mm", "12 mm" ], has_guage_price: true)
    @session = GuageSession.create!(starts_on: Date.current - 30, ends_on: Date.current + 300, created_by: admins(:owner))
    price_size(@tmt, "8 mm", 7000)
    price_size(@tmt, "10 mm", 5500)
    DailyPrice.create!(product: @tmt, admin: admins(:one), priced_on: Date.current - 3, price: 50_000)
    DailyPrice.create!(product: @tmt, admin: admins(:one), priced_on: Date.current - 1, price: 52_000)
    Setting.current.update!(gst_percent: 18, loading_charges: 500)
  end

  def price_size(product, size, price)
    @session.guage_prices.create!(product:, size:, price:, entered_by: admins(:one), updated_by: admins(:one))
  end

  def quote(product_id: @tmt.id, size: "10 mm", quantity: "2")
    QuoteCalculator.new(product_id:, size:, quantity:).call
  end

  test "rate is the latest basic price plus the gauge difference, then loading and GST" do
    q = quote

    assert_equal 52_000, q.basic_price
    assert_equal Date.current - 1, q.basic_priced_on
    assert_equal BigDecimal("57500"), q.rate          # 52,000 + 5,500
    assert_equal BigDecimal("115000"), q.amount       # × 2 MT
    assert_equal BigDecimal("115500"), q.taxable      # + 500 loading
    assert_equal BigDecimal("20790"), q.gst           # 18%
    assert_equal BigDecimal("136290"), q.total
    assert_match(/\AQ-\d{8}-[A-Z0-9]{5}\z/, q.number)
  end

  test "missing loading charges count as zero" do
    Setting.current.update!(loading_charges: nil)

    assert_equal quote.amount, quote.taxable
  end

  test "rejects bad input and anything that isn't priced" do
    assert_raises(QuoteCalculator::Error) { quote(size: "32 mm") }
    assert_raises(QuoteCalculator::Error) { quote(size: "12 mm") }   # listed size, no gauge price
    assert_raises(QuoteCalculator::Error) { quote(product_id: 0) }
    [ "0", "-1", "abc", "", nil, "10001" ].each do |bad|
      assert_raises(QuoteCalculator::Error, "quantity #{bad.inspect}") { quote(quantity: bad) }
    end

    Setting.current.update!(gst_percent: nil)
    assert_raises(QuoteCalculator::Error) { quote }
  end

  test "quotable lists only priced sizes of products with a basic price" do
    beam = Product.create!(slug: "beams", key: "beam", category: "Beams", title: "Beams", position: 2,
                           sizes: [ "100 × 50" ], has_guage_price: true)
    price_size(beam, "100 × 50", 6800) # gauge price but no daily price yet

    assert_equal({ @tmt => [ "8 mm", "10 mm" ] }, QuoteCalculator.quotable)
  end

  test "the PDF renders" do
    pdf = QuotePdf.new(quote).render

    assert pdf.start_with?("%PDF")
  end
end
