# A gauge price session: the date range (normally a year) a set of gauge prices
# is valid for. Opened by an owner or super user; `created_by` records who.
class CreateGuageSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :guage_sessions do |t|
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :admins }

      t.timestamps
    end

    add_check_constraint :guage_sessions, "ends_on >= starts_on", name: "guage_sessions_ends_after_start"
    # Sessions may not overlap, so any date belongs to at most one session. The
    # model validates this too; the constraint holds it under concurrent saves.
    add_exclusion_constraint :guage_sessions, "daterange(starts_on, ends_on, '[]') WITH &&",
                             using: :gist, name: "guage_sessions_no_overlap"
  end
end
