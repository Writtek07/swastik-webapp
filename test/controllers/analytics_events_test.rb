require "test_helper"

# Server-confirmed Google Analytics events: queued by controllers (or views),
# rendered as JSON for app/javascript/lib/analytics.js, never shown as flash
# messages and never carrying personal data.
class AnalyticsEventsTest < ActionDispatch::IntegrationTest
  setup do
    @tmt = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT & Reinforcement", title: "TMT Rebars",
                           summary: "Reinforcement bars.", position: 1, visual: "rebar")
  end

  def analytics_events
    script = css_select("script#analytics-events").first
    script ? JSON.parse(script.text) : []
  end

  def event(name)
    analytics_events.find { |e| e["name"] == name }
  end

  test "a saved enquiry is reported as generate_lead on the page it redirects to" do
    post enquiries_path, params: { enquiry: { name: "Ravi Kumar", email: "ravi@example.com", phone: "9876543210",
                                              product_key: "tmt", message: "Need 20 MT of 12 mm" } }
    follow_redirect!

    lead = event("generate_lead")
    assert_equal({ "form_name" => "enquiry", "product_category" => "TMT & Reinforcement" }, lead["params"])
    assert_no_match(/ravi|9876543210/i, lead.to_json, "personal data must never reach analytics")
    assert_select "[role=status]", count: 1 # the thank-you notice, but no stray analytics "message"
  end

  test "the lead event is sent once, not again on the next page" do
    post enquiries_path, params: { enquiry: { name: "Ravi", email: "ravi@example.com", message: "Quote please" } }
    follow_redirect!
    get about_path

    assert_nil event("generate_lead")
  end

  test "a rejected enquiry reports the failing fields only" do
    post enquiries_path, params: { enquiry: { name: "", email: "not-an-email", message: "" } }
    follow_redirect!

    error = event("enquiry_error")
    assert_includes error["params"]["error_fields"], "email"
    assert_no_match(/not-an-email/, error.to_json)
  end

  test "a quote the server can't price is reported as quote_error" do
    post quotes_path, params: { quote: { product_id: @tmt.id, size: "8 mm", quantity: "2" } }
    follow_redirect!

    assert event("quote_error")["params"]["reason"].present?
  end

  test "product pages report view_item and the catalogue reports view_item_list" do
    get product_path(@tmt.slug)
    item = event("view_item")["params"]["items"].first
    assert_equal({ "item_id" => "tmt-rebars", "item_name" => "TMT Rebars", "item_category" => "TMT & Reinforcement" }, item)

    get products_path
    list = event("view_item_list")["params"]
    assert_equal "Catalogue", list["item_list_name"]
    assert_equal [ "tmt-rebars" ], list["items"].map { |i| i["item_id"] }
  end

  test "pages without events render no analytics payload" do
    get about_path

    assert_select "script#analytics-events", count: 0
  end
end
