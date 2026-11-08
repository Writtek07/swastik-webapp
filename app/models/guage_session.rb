# The window a set of gauge prices is valid for, normally one year (for
# example 6 Apr 2026 – 5 Apr 2027). Owners and super users open sessions; staff
# then enter one gauge price per product size for the session in progress.
#
# Sessions never overlap, so a date belongs to at most one session. Prices can
# only be entered or changed while their session is in progress: an upcoming
# session isn't open yet, and an ended one is a closed record.
class GuageSession < ApplicationRecord
  belongs_to :created_by, class_name: "Admin"
  has_many :guage_prices, dependent: :restrict_with_error

  validates :starts_on, :ends_on, presence: true
  validate :ends_on_or_after_start
  validate :at_most_a_year
  validate :no_overlap
  validate :created_by_owner, if: :created_by

  scope :chronological, -> { order(starts_on: :desc) }
  scope :covering, ->(date) { where("starts_on <= :date AND ends_on >= :date", date: date) }

  def self.current
    covering(Date.current).first
  end

  def in_progress?
    (starts_on..ends_on).cover?(Date.current)
  end

  def upcoming?
    starts_on > Date.current
  end

  def ended?
    ends_on < Date.current
  end

  # "2026" for a calendar year, "2026–27" for a session that spans two.
  def label
    starts_on.year == ends_on.year ? starts_on.year.to_s : "#{starts_on.year}–#{ends_on.strftime('%y')}"
  end

  def date_range
    "#{I18n.l(starts_on, format: '%-d %b %Y')} – #{I18n.l(ends_on, format: '%-d %b %Y')}"
  end

  def status
    if in_progress? then :in_progress
    elsif upcoming? then :upcoming
    else :ended
    end
  end

  private

  def ends_on_or_after_start
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "must be on or after the start date") if ends_on < starts_on
  end

  # A session prices a year at most: 1 Jan – 31 Dec and 6 Apr – 5 Apr both fit.
  def at_most_a_year
    return if starts_on.blank? || ends_on.blank?

    errors.add(:ends_on, "must be within a year of the start date") if ends_on >= starts_on + 1.year
  end

  def no_overlap
    return if starts_on.blank? || ends_on.blank?

    clash = GuageSession.where.not(id: id).where("starts_on <= ? AND ends_on >= ?", ends_on, starts_on).first
    errors.add(:base, "Dates overlap the #{clash.label} session (#{clash.date_range})") if clash
  end

  def created_by_owner
    errors.add(:created_by, "must be an owner or super user") unless created_by.at_least?(:owner)
  end
end
