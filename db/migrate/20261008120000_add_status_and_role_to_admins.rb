class AddStatusAndRoleToAdmins < ActiveRecord::Migration[8.1]
  def change
    # Integer-backed enums (see Admin). Existing admins become active staff, the
    # least-privileged role, so nobody gains access by default; promote owners and
    # super users explicitly.
    add_column :admins, :status, :integer, default: 0, null: false
    add_column :admins, :role, :integer, default: 0, null: false
    add_index :admins, :status
    add_index :admins, :role
  end
end
