# A product family sold by the company.
#
# Products used to live in `Catalog::PRODUCTS` as plain hashes. They are now
# database rows so the admin area can manage them and so daily prices can hang
# off them. `specs` is a jsonb array of [label, value] pairs, mirroring the
# shape the specification table on the product page expects.
class Product < ApplicationRecord
  has_many :daily_prices, dependent: :destroy
  has_many :guage_prices, dependent: :restrict_with_error

  validates :slug, presence: true, uniqueness: true
  validates :key, :category, :title, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be an http(s) URL" },
                        allow_blank: true

  scope :ordered, -> { order(:position, :title) }
  # Products priced per size on the yearly gauge sheet (see GuageSession).
  scope :with_guage_price, -> { where(has_guage_price: true) }

  # [key, category] pairs in display order, used by the catalogue filter chips.
  def self.categories
    ordered.pluck(:key, :category).uniq
  end

  def self.products_for(key)
    return ordered if key.blank? || key == "all"

    ordered.where(key: key)
  end

  def self.product_by_key(key)
    find_by(key: key)
  end

  # Human-readable family name for a category key, or nil when unknown.
  def self.category_name(key)
    where(key: key).pick(:category)
  end

  def to_param
    slug
  end

  # `specs` round-trips as an array of two-element arrays; normalise it so views
  # can destructure without worrying about the stored shape.
  def spec_pairs
    Array(specs).filter_map do |entry|
      label, value = entry
      [ label, value ] if label.present?
    end
  end

  # Text-area views of the list columns for the admin edit form: one entry per
  # line, and specs as "Label: value". Blank lines are dropped on the way in.
  %i[tags sizes applications].each do |column|
    define_method(:"#{column}_text") { Array(public_send(column)).join("\n") }
    define_method(:"#{column}_text=") { |text| public_send(:"#{column}=", Product.lines(text)) }
  end

  def specs_text
    spec_pairs.map { |label, value| "#{label}: #{value}" }.join("\n")
  end

  # Splits on the first colon only, so values such as "Ratio 1:2" survive.
  def specs_text=(text)
    self.specs = Product.lines(text).map { |line| line.split(":", 2).map(&:strip) }
                                    .map { |label, value| [ label, value.to_s ] }
  end

  def self.lines(text)
    text.to_s.split(/\r?\n/).map(&:strip).compact_blank
  end

  def grade
    spec_pairs.to_h["Grade"]
  end

  def price_on(date)
    daily_prices.find_by(priced_on: date)
  end
end
