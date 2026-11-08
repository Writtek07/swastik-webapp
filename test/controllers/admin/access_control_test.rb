require "test_helper"

class Admin::AccessControlTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    host! "admin.example.com"
    @product = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT Bars", title: "TMT Rebars", position: 1,
                               specs: [ [ "Grade", "Fe 500D" ] ], sizes: [ "8 mm" ])
  end

  test "role ranks" do
    assert admins(:super).at_least?(:owner)
    assert admins(:owner).at_least?(:owner)
    assert_not admins(:owner).at_least?(:super_user)
    assert_not admins(:one).at_least?(:owner)
    assert admins(:one).at_least?(:staff)
  end

  test "controllers record the role each action needs" do
    assert_equal :super_user, Admin::ProductsController.required_role(:edit)
    assert_nil Admin::ProductsController.required_role(:show)
    assert_equal :owner, Admin::StaffController.required_role(:update_status)
    assert_equal :owner, Admin::SettingsController.required_role(:update)
    assert_nil Admin::SettingsController.required_role(:show)

    assert Admin::GuageSessionsController.allows?(admins(:owner), :edit)
    assert_not Admin::GuageSessionsController.allows?(admins(:one), :new)
    assert_not Admin::ProductsController.allows?(admins(:owner), :update)
    assert Admin::ProductsController.allows?(admins(:super), :update)
  end

  test "each role only sees links to actions it may use" do
    GuageSession.create!(starts_on: Date.current - 10, ends_on: Date.current + 300, created_by: admins(:owner))
    expectations = { one: false, owner: true, super: true }

    expectations.each do |name, owner_or_above|
      sign_in admins(name)

      get admin_products_path
      assert_select "a[href=?]", edit_admin_product_path(@product), count: name == :super ? 1 : 0
      assert_select "nav[aria-label=Admin] a[href=?]", admin_staff_path, count: owner_or_above ? 1 : 0
      assert_select "nav[aria-label=Admin] a[href=?]", admin_settings_path

      get admin_guage_prices_path
      assert_select "a[href=?]", new_admin_guage_session_path, count: owner_or_above ? 1 : 0
      assert_select "a[href$='/edit'][href*='guage_sessions']", owner_or_above ? { minimum: 1 } : { count: 0 }

      get admin_settings_path
      assert_select "fieldset[disabled]", count: owner_or_above ? 0 : 1
      assert_select "button[type=submit]", text: /Save settings/, count: owner_or_above ? 1 : 0

      sign_out :admin
    end
  end

  test "every role reaches the existing pages" do
    %i[one owner super].each do |name|
      sign_in admins(name)
      [ admin_root_path, admin_daily_prices_path, admin_products_path, admin_product_path(@product) ].each do |path|
        get path
        assert_response :success, "#{name} should reach #{path}"
      end
      sign_out :admin
    end
  end

  test "inactive admins can't sign in" do
    post admin_session_path, params: { admin: { email: admins(:inactive).email, password: "password123" } }

    assert_redirected_to new_admin_session_path
    follow_redirect!
    assert_match "deactivated", response.body
  end

  test "deactivating an admin ends their session" do
    admin = admins(:one)
    sign_in admin
    admin.inactive!

    get admin_root_path
    assert_redirected_to new_admin_session_path
  end

  test "staff can't see the roster" do
    sign_in admins(:one)

    get admin_staff_path
    assert_redirected_to admin_root_path
    follow_redirect!
    assert_select "nav[aria-label=Admin] a", text: "Staff", count: 0
  end

  test "super users see every admin and every role card" do
    DailyPrice.create!(product: @product, admin: admins(:two), priced_on: Date.current, price: 50_000)
    sign_in admins(:super)

    get admin_staff_path

    assert_response :success
    assert_select "nav[aria-label=Admin] a", text: "Staff"
    Admin.find_each { |admin| assert_select "td p", text: admin.email }
    assert_select "tr", text: /#{admins(:two).email}.*Staff.*Active\s*1\b/m
    assert_select ".admin-card .micro", text: "Super users"
    assert_select ".admin-card p", text: Admin.count.to_s
  end

  test "owners don't see super users on the roster or the cards" do
    sign_in admins(:owner)

    get admin_staff_path

    assert_response :success
    assert_select "td p", text: admins(:super).email, count: 0
    assert_select "td p", text: admins(:owner).email
    assert_select "td p", text: admins(:one).email
    assert_select ".admin-card .micro", text: "Super users", count: 0
    assert_select ".admin-card .micro", text: "Owners"
    assert_select ".admin-card p", text: Admin.where.not(role: :super_user).count.to_s
    assert_select "th", text: "Last IP", count: 0
  end

  test "roster filters by status" do
    sign_in admins(:owner)

    get admin_staff_path(status: "inactive")
    assert_select "tbody tr", count: 1
    assert_select "td p", text: admins(:inactive).email
  end

  test "status switches only appear for admins the viewer may change" do
    sign_in admins(:owner)
    get admin_staff_path

    assert_select "tr##{dom_id(admins(:one))} button[role=switch][aria-checked=true]"
    assert_select "tr##{dom_id(admins(:inactive))} button[role=switch][aria-checked=false]"
    assert_select "tr##{dom_id(admins(:owner))} button[role=switch]", count: 0
    sign_out :admin

    sign_in admins(:super)
    get admin_staff_path
    assert_select "tr##{dom_id(admins(:owner))} button[role=switch]"
    assert_select "tr##{dom_id(admins(:super))} button[role=switch]", count: 0
  end

  test "toggling a status redraws the row and the cards" do
    sign_in admins(:owner)

    patch admin_staff_status_path(admins(:one)), as: :turbo_stream

    assert_response :success
    assert admins(:one).reload.inactive?
    assert_select "turbo-stream[action=replace][target=staff_summary]"
    assert_select "turbo-stream[action=replace][target=#{dom_id(admins(:one))}] button[aria-checked=false]"

    patch admin_staff_status_path(admins(:one)), as: :turbo_stream
    assert admins(:one).reload.active?
  end

  test "a toggled row leaves a status-filtered roster" do
    sign_in admins(:owner)

    patch admin_staff_status_path(admins(:one)), params: { status: "active" }, as: :turbo_stream

    assert_select "turbo-stream[action=remove][target=#{dom_id(admins(:one))}]"
  end

  test "the HTML fallback redirects back to the roster" do
    sign_in admins(:super)

    patch admin_staff_status_path(admins(:owner))

    assert_redirected_to admin_staff_path
    assert admins(:owner).reload.inactive?
  end

  test "status changes outside the viewer's reach are refused" do
    sign_in admins(:owner)

    patch admin_staff_status_path(admins(:owner)), as: :turbo_stream
    assert_response :forbidden
    patch admin_staff_status_path(admins(:super))
    assert_response :not_found
    sign_out :admin

    sign_in admins(:one)
    patch admin_staff_status_path(admins(:two))
    assert_redirected_to admin_root_path

    assert admins(:owner).reload.active?
    assert admins(:super).reload.active?
    assert admins(:two).reload.active?
  end

  test "only super users can edit a product" do
    %i[one owner].each do |name|
      sign_in admins(name)

      get edit_admin_product_path(@product)
      assert_redirected_to admin_root_path
      patch admin_product_path(@product), params: { product: { title: "Hijacked" } }
      assert_redirected_to admin_root_path

      get admin_product_path(@product)
      assert_select "a", text: /Edit details/, count: 0
      sign_out :admin
    end

    assert_equal "TMT Rebars", @product.reload.title
  end

  test "super users update product details" do
    sign_in admins(:super)

    get admin_product_path(@product)
    assert_select "a[href=?]", edit_admin_product_path(@product)
    get edit_admin_product_path(@product)
    assert_response :success
    assert_select "textarea[name='product[specs_text]']", text: "Grade: Fe 500D"

    patch admin_product_path(@product), params: { product: {
      title: "TMT Bars Fe 550", summary: "Higher grade", position: 3,
      specs_text: "Grade: Fe 550D\n\nRatio: 1:1.08\n", sizes_text: "10 mm\n12 mm", tags_text: "", slug: "renamed"
    } }

    assert_redirected_to admin_product_path(@product)
    @product.reload
    assert_equal "TMT Bars Fe 550", @product.title
    assert_equal 3, @product.position
    assert_equal [ [ "Grade", "Fe 550D" ], [ "Ratio", "1:1.08" ] ], @product.specs
    assert_equal [ "10 mm", "12 mm" ], @product.sizes
    assert_equal [], @product.tags
    assert_equal "tmt-rebars", @product.slug, "slug is not editable"
  end

  test "invalid product details re-render the form" do
    sign_in admins(:super)

    patch admin_product_path(@product), params: { product: { title: "", image_url: "not a url" } }

    assert_response :unprocessable_content
    assert_select "[role=alert] li", text: "Title can't be blank"
    assert_select "[role=alert] li", text: /Image url must be an http\(s\) URL/
    assert_equal "TMT Rebars", @product.reload.title
  end
end
