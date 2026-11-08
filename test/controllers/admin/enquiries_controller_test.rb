require "test_helper"

class Admin::EnquiriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { host! "admin.example.com" }

  test "every role can list and open enquiries" do
    %i[one owner super].each do |name|
      sign_in admins(name)

      get admin_enquiries_path
      assert_response :success
      assert_select "nav[aria-label=Admin] a", text: "Enquiries"
      assert_select "tbody tr", count: Enquiry.count

      get admin_enquiry_path(enquiries(:structural))
      assert_response :success
      assert_match enquiries(:structural).message, response.body
      sign_out :admin
    end
  end

  test "lists newest first and searches" do
    sign_in admins(:one)
    enquiries(:reinforcement).update!(created_at: 1.day.ago)
    enquiries(:structural).update!(created_at: 2.days.ago)

    get admin_enquiries_path
    assert_select "tbody tr:first-child td a", text: enquiries(:reinforcement).name
    assert_select "[aria-label='Filter by status']", count: 0

    get admin_enquiries_path(q: "vindhya")
    assert_select "tbody tr", count: 1
    assert_select "td a", text: enquiries(:structural).name

    get admin_enquiries_path(q: "nobody-matches")
    assert_match "No enquiries match", response.body
  end

  test "signed-out visitors are sent to sign in" do
    get admin_enquiries_path

    assert_redirected_to new_admin_session_path
  end
end
