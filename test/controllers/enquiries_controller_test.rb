require "test_helper"

class EnquiriesControllerTest < ActionDispatch::IntegrationTest
  test "creates an enquiry and redirects with a notice" do
    assert_difference "Enquiry.count", 1 do
      post enquiries_path, params: {
        enquiry: {
          name: "Ravi Sharma",
          email: "ravi@vindhya.example",
          product_key: "structures",
          message: "Need 24 tonnes of parallel flange beams cut to length."
        }
      }
    end

    assert_redirected_to contact_path(anchor: "enquiry")
    assert_equal "new", Enquiry.last.status
  end

  test "rejects an enquiry without the required fields" do
    assert_no_difference "Enquiry.count" do
      post enquiries_path, params: { enquiry: { name: "", email: "bad", message: "" } }
    end

    assert_redirected_to contact_path(anchor: "enquiry")
    assert_match(/can't be blank/, flash[:alert])
  end
end
