require "test_helper"

class Admin::GuagePricesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! "admin.example.com"
    @tmt = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars", position: 1,
                           sizes: [ "8 mm", "10 mm" ], has_guage_price: true)
    @flat = Product.create!(slug: "ms-flat", key: "flat", category: "Flats", title: "MS Flat", position: 2,
                            sizes: [ "100 × 5" ], has_guage_price: true)
    @beam = Product.create!(slug: "beams", key: "beam", category: "Beams", title: "Beams", position: 3,
                            sizes: [ "100 × 50" ], has_guage_price: false)
  end

  def open_session(starts_on: Date.current - 30, ends_on: Date.current + 300)
    GuageSession.create!(starts_on: starts_on, ends_on: ends_on, created_by: admins(:owner))
  end

  def entries(*rows)
    rows.each_with_index.to_h { |(product, size, price), i| [ i.to_s, { product_id: product.id, size: size, price: price } ] }
  end

  test "without a session, staff are told to ask an owner and owners can open one" do
    sign_in admins(:one)
    get admin_guage_prices_path
    assert_response :success
    assert_match "An owner or super user needs to open one", response.body
    assert_select "a[href=?]", new_admin_guage_session_path, count: 0
    sign_out :admin

    sign_in admins(:owner)
    get admin_guage_prices_path
    assert_select "a[href=?]", new_admin_guage_session_path
  end

  test "the sheet lists every size of flagged products only" do
    open_session
    sign_in admins(:one)

    get admin_guage_prices_path

    assert_select "input[aria-label=?]", "TMT Rebars 8 mm gauge price"
    assert_select "input[aria-label=?]", "TMT Rebars 10 mm gauge price"
    assert_select "input[aria-label=?]", "MS Flat 100 × 5 gauge price"
    assert_select "h2", text: "Beams", count: 0
  end

  test "staff enter prices, stamped as the entering admin" do
    guage_session = open_session
    sign_in admins(:one)

    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "7000" ], [ @tmt, "10 mm", "" ], [ @flat, "100 × 5", "8100" ]) }

    assert_redirected_to admin_guage_prices_path
    assert_equal 2, guage_session.guage_prices.count
    price = guage_session.guage_prices.find_by!(product: @flat, size: "100 × 5")
    assert_equal 8100, price.price
    assert_equal admins(:one), price.entered_by
    assert_equal admins(:one), price.updated_by
  end

  test "a saved price is updated, never duplicated, and keeps its original author" do
    guage_session = open_session
    GuagePrice.create!(guage_session: guage_session, product: @tmt, size: "8 mm", price: 7000,
                       entered_by: admins(:one), updated_by: admins(:one))
    sign_in admins(:two)

    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "7200" ]) }

    assert_equal 1, guage_session.guage_prices.count
    price = guage_session.guage_prices.sole
    assert_equal 7200, price.price
    assert_equal admins(:one), price.entered_by
    assert_equal admins(:two), price.updated_by
  end

  test "blank inputs don't clear a saved price" do
    guage_session = open_session
    GuagePrice.create!(guage_session: guage_session, product: @tmt, size: "8 mm", price: 7000,
                       entered_by: admins(:one), updated_by: admins(:one))
    sign_in admins(:one)

    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "" ]) }

    assert_equal 7000, guage_session.guage_prices.sole.price
    assert_match "Nothing changed", flash[:alert]
  end

  test "unflagged products and unknown sizes are refused, and nothing is saved" do
    guage_session = open_session
    sign_in admins(:one)

    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "7000" ], [ @beam, "100 × 50", "9000" ], [ @tmt, "99 mm", "1" ]) }

    assert_equal 0, guage_session.guage_prices.count
    assert_match "doesn't take gauge prices", flash[:alert]
    assert_match "isn't one of TMT Rebars's sizes", flash[:alert]
  end

  test "prices go into the session in progress; outside any session nothing can be entered" do
    ended = open_session(starts_on: Date.current - 400, ends_on: Date.current - 40)
    sign_in admins(:one)

    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "7000" ]) }
    assert_match "no gauge session in progress", flash[:alert]
    assert_equal 0, GuagePrice.count

    current = open_session(starts_on: Date.current - 39, ends_on: Date.current + 300)
    post admin_guage_prices_path, params: { entries: entries([ @tmt, "8 mm", "7000" ]) }
    assert_equal current, GuagePrice.sole.guage_session
    assert_empty ended.guage_prices
  end

  test "an ended session is shown read-only and its prices can't change" do
    ended = open_session(starts_on: Date.current - 400, ends_on: Date.current - 40)
    price = GuagePrice.new(guage_session: ended, product: @tmt, size: "8 mm", price: 7000,
                           entered_by: admins(:one), updated_by: admins(:one))
    price.save!(validate: false)
    sign_in admins(:one)

    get admin_guage_prices_path(session_id: ended.id)
    assert_select "input[type=number]", count: 0
    assert_match "read-only", response.body
    assert_select "td span", text: "₹7,000.00"

    assert_not price.update(price: 1)
    assert_match "closed", price.errors[:base].first
  end

  test "owners open and edit sessions, stamped with their name; staff can't" do
    sign_in admins(:one)
    get new_admin_guage_session_path
    assert_redirected_to admin_root_path
    post admin_guage_sessions_path, params: { guage_session: { starts_on: Date.current, ends_on: Date.current + 364 } }
    assert_equal 0, GuageSession.count
    sign_out :admin

    sign_in admins(:owner)
    post admin_guage_sessions_path, params: { guage_session: { starts_on: Date.current, ends_on: Date.current + 364 } }
    guage_session = GuageSession.sole
    assert_redirected_to admin_guage_prices_path(session_id: guage_session.id)
    assert_equal admins(:owner), guage_session.created_by

    patch admin_guage_session_path(guage_session), params: { guage_session: { ends_on: Date.current + 400 } }
    assert_response :unprocessable_content
    assert_select "[role=alert] li", text: /within a year/

    sign_out :admin
    sign_in admins(:super)
    patch admin_guage_session_path(guage_session), params: { guage_session: { ends_on: Date.current + 200 } }
    assert_equal Date.current + 200, guage_session.reload.ends_on
    assert_equal admins(:owner), guage_session.created_by, "the opener doesn't change on edit"
  end

  test "super users can flag a product for gauge prices" do
    sign_in admins(:super)

    patch admin_product_path(@beam), params: { product: { has_guage_price: "1" } }

    assert @beam.reload.has_guage_price?
  end
end
