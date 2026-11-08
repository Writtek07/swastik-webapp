# The price a product carries on a given day.
#
# One row per product per day, entered by a signed-in admin. `admin` records who
# created the entry so the price sheet can show provenance.
class DailyPrice < ApplicationRecord
  belongs_to :product
  belongs_to :admin

  validates :priced_on, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :priced_on, message: "already has a price for this date" }

  scope :for_date, ->(date) { where(priced_on: date) }
  scope :recent, -> { order(priced_on: :desc, updated_at: :desc) }

  # Each row gains a `previous_price` attribute: the same product's price on the
  # most recent earlier day it was priced. The window runs in a subquery so that
  # filters applied afterwards (date range, product) don't hide the prior day the
  # comparison needs.
  scope :with_previous_price, -> {
    from(
      unscoped.select(
        "daily_prices.*, LAG(price) OVER (PARTITION BY product_id ORDER BY priced_on) AS previous_price"
      ),
      :daily_prices
    )
  }

  def self.today
    for_date(Date.current)
  end

  # The latest price for each product strictly before `date`, keyed by product id.
  def self.latest_before(date)
    where(priced_on: ...date)
      .select("DISTINCT ON (product_id) daily_prices.*")
      .order(:product_id, priced_on: :desc)
      .index_by(&:product_id)
  end

  # Signed change against `previous_price` (only set via `with_previous_price`).
  def change
    return if !has_attribute?(:previous_price) || self[:previous_price].nil?

    price - self[:previous_price]
  end

  def edited?
    updated_at - created_at > 1.second
  end
end
