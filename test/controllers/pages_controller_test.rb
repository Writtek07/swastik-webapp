require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home renders the hero and featured products" do
    get root_path

    assert_response :success
    assert_select "h1", text: /Steel that holds up/
    assert_select "[data-controller='hero-video']"
    assert_select "[data-controller='reveal']"
  end

  test "about renders milestones and values" do
    get about_path

    assert_response :success
    assert_select "h1", text: /Three decades/
    assert_select "li", text: /Founded in Raipur/
  end

  test "plant renders the six process stages" do
    get plant_path

    assert_response :success
    assert_select "h1", text: /Six stages/
    assert_select "h3", text: "Raw material intake"
    assert_select "h3", text: "Dispatch & logistics"
  end

  test "clients renders the clientele and approvals" do
    get clients_path

    assert_response :success
    assert_select "h1", text: /Trusted where/
    assert_select "li", text: /ISO 9001:2015 quality management/
  end

  test "contact renders the enquiry form" do
    get contact_path

    assert_response :success
    assert_select "form[action=?]", enquiries_path
    assert_select "input[name='enquiry[email]']"
  end

  test "contact preselects the product family from the query string" do
    get contact_path(product: "tmt")

    assert_response :success
    assert_select "select[name='enquiry[product_key]'] option[selected][value='tmt']"
  end
end
