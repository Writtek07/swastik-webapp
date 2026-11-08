require "test_helper"

class QuotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tmt = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars", position: 1,
                           sizes: [ "8 mm" ], has_guage_price: true, image_url: "https://example.com/tmt.jpg")
    session = GuageSession.create!(starts_on: Date.current - 30, ends_on: Date.current + 300, created_by: admins(:owner))
    session.guage_prices.create!(product: @tmt, size: "8 mm", price: 7000, entered_by: admins(:one), updated_by: admins(:one))
    DailyPrice.create!(product: @tmt, admin: admins(:one), priced_on: Date.current, price: 50_000)
    Setting.current.update!(gst_percent: 18, loading_charges: 500)
  end

  test "the home page offers priced products in the quote form" do
    get root_path

    assert_select "form[action=?]", quotes_path do
      assert_select "select[name='quote[product_id]'] option[value=?]", @tmt.id.to_s
    end
  end

  test "a valid quote downloads as a PDF" do
    post quotes_path, params: { quote: { product_id: @tmt.id, size: "8 mm", quantity: "3.5" } }

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_match(/attachment; filename="Q-\d{8}-\w{5}\.pdf"/, response.headers["Content-Disposition"])
    assert response.body.start_with?("%PDF")
    assert_includes response.body, "/Subtype /Image", "the quotation should carry the logo"
  end

  test "an invalid quote returns to the form with the reason" do
    post quotes_path, params: { quote: { product_id: @tmt.id, size: "8 mm", quantity: "0" } }

    assert_redirected_to root_path(anchor: "quote")
    assert_match "quantity", flash[:alert]
  end
end
