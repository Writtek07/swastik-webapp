# The gauge price for one size of a product within a gauge session.
#
# There is exactly one row per session, product and size: once a size is priced
# for the session it can be updated but not added again. `entered_by` keeps who
# first entered it; `updated_by` is whoever changed it last. Rows can only be
# written while their session is in progress.
class GuagePrice < ApplicationRecord
  belongs_to :guage_session
  belongs_to :product
  belongs_to :entered_by, class_name: "Admin"
  belongs_to :updated_by, class_name: "Admin"

  validates :size, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :size, uniqueness: { scope: [ :guage_session_id, :product_id ], message: "already has a gauge price for this session" }
  validate :session_in_progress, if: :guage_session
  validate :product_takes_guage_prices, :size_listed_for_product, on: :create, if: :product

  def edited?
    updated_at - created_at > 1.second
  end

  private

  def session_in_progress
    return if guage_session.in_progress?

    errors.add(:base, "The #{guage_session.label} session is #{guage_session.ended? ? 'closed' : 'not open yet'}")
  end

  def product_takes_guage_prices
    errors.add(:product, "doesn't take gauge prices") unless product.has_guage_price?
  end

  def size_listed_for_product
    errors.add(:size, "isn't one of #{product.title}'s sizes") unless product.sizes.include?(size)
  end
end
