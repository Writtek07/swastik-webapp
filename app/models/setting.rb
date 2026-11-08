# Company-wide billing settings: GSTIN, GST rate and loading charges.
#
# A single row, read and written through `Setting.current`. Owners and super
# users edit it from the admin Settings page; `updated_by` records who saved it
# last.
class Setting < ApplicationRecord
  # 2-digit state code, 10-character PAN, entity number, "Z", check character.
  GSTN_FORMAT = /\A\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]\z/

  belongs_to :updated_by, class_name: "Admin", optional: true

  normalizes :gstn, with: ->(gstn) { gstn.strip.upcase.delete(" ").presence }

  validates :gstn, format: { with: GSTN_FORMAT, message: "must be a 15-character GSTIN, e.g. 22AAAAA0000A1Z5" }, allow_nil: true
  validates :gst_percent, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :loading_charges, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # The settings row, created empty on first use. A concurrent first save is
  # caught by the singleton index and retried as a read.
  def self.current
    first || create!
  rescue ActiveRecord::RecordNotUnique
    first!
  end
end
