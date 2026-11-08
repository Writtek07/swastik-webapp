# The Admin model declares Devise's :trackable module, which writes these
# columns on every sign-in. Without them the first login raises.
class AddTrackableToAdmins < ActiveRecord::Migration[8.1]
  def change
    change_table :admins, bulk: true do |t|
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
    end
  end
end
