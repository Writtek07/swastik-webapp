class Admin < ApplicationRecord
  # Admins are provisioned deliberately (seeds or console), so there is no
  # :registerable module and no sign-up route.
  devise :database_authenticatable, :recoverable, :rememberable, :validatable,
         :timeoutable, :trackable

  has_many :daily_prices, dependent: :restrict_with_error
  has_many :created_guage_sessions, class_name: "GuageSession", foreign_key: :created_by_id,
                                    inverse_of: :created_by, dependent: :restrict_with_error
  has_many :entered_guage_prices, class_name: "GuagePrice", foreign_key: :entered_by_id,
                                  inverse_of: :entered_by, dependent: :restrict_with_error
  has_many :updated_settings, class_name: "Setting", foreign_key: :updated_by_id,
                              inverse_of: :updated_by, dependent: :nullify

  enum :status, { active: 0, inactive: 1 }, default: :active, validate: true

  # Ordered by privilege: the integer value is the rank, so `at_least?` can
  # compare them. Add new roles in rank order and keep existing values stable.
  enum :role, { staff: 0, owner: 1, super_user: 2 }, default: :staff, validate: true

  # Admins `viewer` may see on the roster: everyone at or below their own rank,
  # so owners see owners and staff but not super users.
  scope :visible_to, ->(viewer) { where(role: roles.select { |_, rank| rank <= roles.fetch(viewer.role) }.keys) }

  # True when this admin's role ranks at or above `role` (:staff, :owner or
  # :super_user). An unknown role name raises rather than silently denying.
  def at_least?(role)
    Admin.roles.fetch(self.role) >= Admin.roles.fetch(role.to_s)
  end

  # Who may activate or deactivate whom: never yourself (that would be a
  # one-click lockout), super users anyone else, owners only staff. Owners can
  # see fellow owners on the roster but can't switch them off.
  def can_change_status_of?(other)
    return false if other == self

    super_user? || (owner? && other.staff?)
  end

  # Inactive admins keep their history (prices stay attributed to them) but can
  # no longer sign in; Devise also signs out an existing session on its next
  # request.
  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :deactivated
  end

  # A readable label for provenance columns: "priya.shah@…" becomes "Priya Shah".
  def display_name
    email.to_s.split("@").first.to_s.tr("._-", " ").squish.titleize.presence || email
  end

  def initials
    display_name.split.first(2).map { |word| word[0] }.join.upcase
  end
end
