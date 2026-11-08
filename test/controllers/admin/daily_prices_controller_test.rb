require "test_helper"

class Admin::DailyPricesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! "admin.example.com"
    @rebar = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars", position: 1)
    @angle = Product.create!(slug: "ms-angles", key: "structural", category: "Structural", title: "MS Angles", position: 2)
    @one = admins(:one)
    @two = admins(:two)
  end

  test "redirects to sign in when signed out" do
    get admin_daily_prices_path

    assert_redirected_to new_admin_session_path
  end

  test "sign in page renders and lands on the console" do
    get new_admin_session_path
    assert_response :success
    assert_select "h2", "Sign in"

    post admin_session_path, params: { admin: { email: @one.email, password: "password123" } }
    assert_redirected_to admin_root_path
  end

  test "sheet lists every product and the history" do
    sign_in @one
    DailyPrice.create!(product: @rebar, admin: @two, priced_on: Date.current - 1, price: 52_000)
    DailyPrice.create!(product: @rebar, admin: @two, priced_on: Date.current - 2, price: 51_000)

    get admin_daily_prices_path

    assert_response :success
    assert_select "input[name='prices[#{@rebar.id}][price]']"
    assert_select "input[name='prices[#{@angle.id}][price]']"
    assert_select "#history td span", text: "Admin Two", count: 2
    assert_select "#history .admin-delta--up", text: /₹1,000\.00/
  end

  test "history is paginated and keeps filters across pages" do
    sign_in @one
    # 30 days of rebar prices rising by 100 a day: 30 entries, 25 per page.
    30.times { |i| DailyPrice.create!(product: @rebar, admin: @two, priced_on: Date.current - i, price: 50_000 - (i * 100)) }

    get admin_daily_prices_path(product_id: @rebar.id)
    assert_response :success
    assert_select "turbo-frame#price_history"
    assert_select "#history tbody tr:not(.admin-table__group)", 25
    assert_select "#history nav.pagy a[href*='page=2'][href*='product_id=#{@rebar.id}']"
    assert_match(/Showing\s*<span[^>]*>1–25<\/span>\s*of\s*<span[^>]*>30<\/span>/, response.body)

    get admin_daily_prices_path(product_id: @rebar.id, page: 2)
    assert_select "#history tbody tr:not(.admin-table__group)", 5
    # The oldest day on page 2 has no earlier price; the rest still compare
    # against the previous day even when it sits on page 1.
    assert_select "#history .admin-delta--up", 4
    assert_select "#history .admin-delta--new", 1
  end

  test "a page past the end falls back to the last page" do
    sign_in @one
    DailyPrice.create!(product: @rebar, admin: @two, priced_on: Date.current, price: 50_000)

    get admin_daily_prices_path(page: 99)

    assert_response :success
    assert_select "#history tbody tr:not(.admin-table__group)", 1
  end

  test "create stamps new prices with the signed-in admin" do
    sign_in @one

    assert_difference -> { DailyPrice.count }, 1 do
      post admin_daily_prices_path, params: {
        priced_on: Date.current,
        prices: {
          @rebar.id => { price: "53250.50", notes: "Mill revision" },
          @angle.id => { price: "" }
        }
      }
    end

    price = DailyPrice.last
    assert_equal @one, price.admin
    assert_equal Date.current, price.priced_on
    assert_equal BigDecimal("53250.50"), price.price
    assert_redirected_to admin_daily_prices_path(priced_on: Date.current)
  end

  test "editing keeps the original creator" do
    existing = DailyPrice.create!(product: @rebar, admin: @two, priced_on: Date.current, price: 50_000)
    sign_in @one

    post admin_daily_prices_path, params: { priced_on: Date.current, prices: { @rebar.id => { price: "50500" } } }

    assert_equal 50_500, existing.reload.price
    assert_equal @two, existing.admin
  end

  test "future dates are clamped to today" do
    sign_in @one

    post admin_daily_prices_path, params: { priced_on: Date.current + 3, prices: { @rebar.id => { price: "1" } } }

    assert_equal Date.current, DailyPrice.last.priced_on
  end

  test "invalid rows are reported" do
    sign_in @one

    post admin_daily_prices_path, params: { priced_on: Date.current, prices: { @rebar.id => { price: "-5" } } }

    assert_equal 0, DailyPrice.count
    assert_match "TMT Rebars", flash[:alert]
  end
end

class Admin::ConsolePagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! "admin.example.com"
    @product = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars")
    DailyPrice.create!(product: @product, admin: admins(:one), priced_on: Date.current, price: 52_000)
    sign_in admins(:two)
  end

  test "dashboard, product list and product history render" do
    get admin_root_path
    assert_response :success
    assert_select "h1", /Admin/

    get admin_products_path
    assert_response :success

    get admin_product_path(@product)
    assert_response :success
    assert_select "td", /₹52,000\.00/
  end

  test "product history is paginated" do
    30.times { |i| DailyPrice.create!(product: @product, admin: admins(:one), priced_on: Date.current - i - 1, price: 40_000) }

    get admin_product_path(@product, page: 2)

    assert_response :success
    assert_select "turbo-frame#product_price_history tbody tr", 6
    assert_select "nav.pagy a.current", "2"
  end

  test "sign out returns to the sign in page" do
    delete destroy_admin_session_path
    assert_redirected_to new_admin_session_path
  end
end
