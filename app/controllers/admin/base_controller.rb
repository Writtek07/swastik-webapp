# Shared behaviour for every controller behind the admin subdomain.
#
# The whole namespace requires a signed-in admin, and the layout drops the
# public marketing chrome in favour of the console shell. Devise's
# `current_admin` (from `devise_for :admins`) identifies who is acting, and is
# what stamps each daily price.
class Admin::BaseController < ApplicationController
  include Pagy::Backend

  layout "admin"

  before_action :authenticate_admin!

  # Minimum role per action ("*" = every action), filled in by require_role.
  # Views read it through AdminHelper#admin_can? to hide links an admin can't
  # follow, so the controller stays the single source of truth.
  class_attribute :role_requirements, instance_writer: false, default: {}.freeze

  # Every admin page is open to all roles unless a controller narrows it:
  #
  #   require_role :owner                     # owners and super users
  #   require_role :super_user, only: :update # super users, one action
  def self.require_role(role, only: nil)
    actions = only ? Array(only).map(&:to_s) : [ "*" ]
    self.role_requirements = role_requirements.merge(actions.index_with(role.to_sym)).freeze
    before_action(**{ only: only }.compact) { authorize_role!(role) }
  end

  # The role `action` needs, or nil when every role may reach it.
  def self.required_role(action)
    role_requirements[action.to_s] || role_requirements["*"]
  end

  def self.allows?(admin, action)
    role = required_role(action)
    role.nil? || admin.at_least?(role)
  end

  private

  def authorize_role!(role)
    return if current_admin.at_least?(role)

    respond_to do |format|
      format.html { redirect_to admin_root_path, alert: "You don't have access to that page." }
      format.any { head :forbidden }
    end
  end
end
