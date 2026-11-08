require "test_helper"

class Admin::SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { host! "admin.example.com" }

  VALID = { gstn: "22aaaaa0000a1z5", gst_percent: "18", loading_charges: "300" }.freeze

  test "owners save settings and are shown as the last editor" do
    sign_in admins(:owner)

    patch admin_settings_path, params: { setting: VALID }

    assert_redirected_to admin_settings_path
    setting = Setting.current
    assert_equal "22AAAAA0000A1Z5", setting.gstn
    assert_equal 18, setting.gst_percent
    assert_equal 300, setting.loading_charges
    assert_equal admins(:owner), setting.updated_by

    follow_redirect!
    assert_select "#settings-last-updated", text: /Last updated by #{admins(:owner).display_name}/
  end

  test "a later save by a super user updates the same row and the editor" do
    sign_in admins(:owner)
    patch admin_settings_path, params: { setting: VALID }
    sign_out :admin

    sign_in admins(:super)
    patch admin_settings_path, params: { setting: VALID.merge(gst_percent: "12") }

    assert_equal 1, Setting.count
    assert_equal 12, Setting.current.gst_percent
    assert_equal admins(:super), Setting.current.updated_by
  end

  test "staff see the settings read-only and can't save" do
    sign_in admins(:one)

    get admin_settings_path
    assert_response :success
    assert_select "fieldset[disabled]"
    assert_select "button[type=submit]", text: /Save settings/, count: 0

    patch admin_settings_path, params: { setting: VALID }
    assert_redirected_to admin_root_path
    assert_nil Setting.current.gstn
  end

  test "invalid values re-render with errors and aren't saved" do
    sign_in admins(:owner)

    patch admin_settings_path, params: { setting: { gstn: "12345", gst_percent: "150", loading_charges: "-1" } }

    assert_response :unprocessable_content
    assert_select "[role=alert] li", count: 3
    assert_nil Setting.current.reload.gstn
    assert_nil Setting.current.updated_by
  end

  test "saving unchanged values doesn't claim an update" do
    sign_in admins(:owner)
    patch admin_settings_path, params: { setting: VALID }
    sign_out :admin

    sign_in admins(:super)
    patch admin_settings_path, params: { setting: VALID }

    assert_equal "Nothing changed.", flash[:alert]
    assert_equal admins(:owner), Setting.current.updated_by
  end
end
