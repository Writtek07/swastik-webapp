# Company billing settings. Every role can read them; owners and super users
# can change them, and the page shows who saved them last.
class Admin::SettingsController < Admin::BaseController
  require_role :owner, only: :update

  def show
    @setting = Setting.current
  end

  def update
    @setting = Setting.current
    @setting.assign_attributes(setting_params)

    if !@setting.changed?
      redirect_to admin_settings_path, alert: "Nothing changed."
    elsif @setting.update(updated_by: current_admin)
      redirect_to admin_settings_path, notice: "Settings saved."
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def setting_params
    params.expect(setting: %i[gstn gst_percent loading_charges])
  end
end
