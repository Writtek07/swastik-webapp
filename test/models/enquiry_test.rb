require "test_helper"

class EnquiryTest < ActiveSupport::TestCase
  test "is valid with the required attributes" do
    enquiry = Enquiry.new(name: "Ravi Sharma", email: "ravi@example.com", message: "Need 20 tonnes of Fe 500D.")

    assert enquiry.valid?
    assert_equal "new", enquiry.status
  end

  test "requires a name, email and message" do
    enquiry = Enquiry.new

    assert_not enquiry.valid?
    assert_includes enquiry.errors[:name], "can't be blank"
    assert_includes enquiry.errors[:email], "can't be blank"
    assert_includes enquiry.errors[:message], "can't be blank"
  end

  test "rejects a malformed email address" do
    enquiry = Enquiry.new(name: "Ravi", email: "not-an-email", message: "Quote please")

    assert_not enquiry.valid?
    assert enquiry.errors[:email].any?
  end

  test "rejects a status outside the allowed set" do
    enquiry = Enquiry.new(name: "Ravi", email: "ravi@example.com", message: "Quote please", status: "archived")

    assert_not enquiry.valid?
    assert_includes enquiry.errors[:status], "is not included in the list"
  end

  test "product_name resolves the catalogue family name" do
    assert_equal "TMT & Reinforcement", Enquiry.new(product_key: "tmt").product_name
  end

  test "product_name falls back for an unknown or blank key" do
    assert_equal "General enquiry", Enquiry.new(product_key: nil).product_name
    assert_equal "unknown-family", Enquiry.new(product_key: "unknown-family").product_name
  end
end
