class Enquiry < ApplicationRecord
  # STATUSES = %w[new contacted quoted won closed].freeze

  validates :name, presence: true, length: { maximum: 120 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 4000 }
  # validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }

  # Human-readable product family for the enquiry, falling back to the raw key.
  def product_name
    Catalog.category_name(product_key) || product_key.presence || "General enquiry"
  end
end
