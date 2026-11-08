# The admin roster: everyone with a back-office account, their role, status and
# activity. Owners and super users only, and each sees only admins at or below
# their own rank (see Admin.visible_to), cards included.
class Admin::StaffController < Admin::BaseController
  require_role :owner

  def index
    load_summary
    @status = status_filter

    @pagy, @admins = pagy(roster.then { |scope| @status ? scope.where(status: @status) : scope })
  end

  # Flips an admin between active and inactive from the roster's switch. Answers
  # with Turbo Streams that redraw the row and the summary cards in place; plain
  # HTML requests fall back to a redirect.
  def update_status
    # Looked up through the visible roster so an owner gets a 404, not a hint,
    # for a super user's id.
    admin = roster.find(params[:id])

    unless current_admin.can_change_status_of?(admin)
      return respond_to do |format|
        format.turbo_stream { head :forbidden }
        format.html { redirect_to admin_staff_path, alert: "You can't change #{admin.display_name}'s status." }
      end
    end

    admin.update!(status: admin.active? ? :inactive : :active)
    load_summary
    @status = status_filter

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("staff_summary", partial: "admin/staff/summary"),
          # A row that no longer matches the status filter leaves the table.
          if @status.nil? || admin.status == @status
            turbo_stream.replace(admin, partial: "admin/staff/admin_row", locals: { admin: admin })
          else
            turbo_stream.remove(admin)
          end
        ]
      end
      format.html do
        redirect_to admin_staff_path(status: @status),
                    notice: "#{admin.display_name} is now #{admin.status}."
      end
    end
  end

  private

  # The price count is a correlated subquery rather than a join + GROUP BY so
  # the relation stays ungrouped and Pagy can count it normally.
  def roster
    Admin.visible_to(current_admin)
         .select("admins.*, (SELECT COUNT(*) FROM daily_prices WHERE daily_prices.admin_id = admins.id) AS prices_count")
         .order(role: :desc, email: :asc)
  end

  def load_summary
    visible = Admin.visible_to(current_admin)
    @roles = Admin.roles.keys.select { |role| current_admin.at_least?(role) }
    @counts = { total: visible.count, active: visible.active.count }
              .merge(visible.group(:role).count.transform_keys(&:to_sym))
  end

  def status_filter
    Admin.statuses.key?(params[:status]) ? params[:status] : nil
  end
end
