require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index lists every product family" do
    get products_path

    assert_response :success
    assert_select "[data-catalog-target='card']", count: Catalog::PRODUCTS.length
    assert_select "[data-catalog-target='chip']", count: Catalog.categories.length + 1
  end

  test "index marks the active category chip" do
    get products_path(category: "tmt")

    assert_response :success
    assert_select "[data-catalog-target='chip'][data-filter='tmt'].is-active"
  end

  test "show renders the specification for a family" do
    get product_path("tmt-rebars")

    assert_response :success
    assert_select "h1", text: "TMT Rebars"
    assert_select "dd", text: "Fe 500 / Fe 500D / Fe 550D"
    assert_select "span", text: "32 mm"
  end

  test "show redirects for an unknown slug" do
    get product_path("does-not-exist")

    assert_redirected_to products_path
  end
end
