# Company-wide billing settings. There is only ever one row (see Setting.current);
# the unique index on a constant expression makes a second row impossible.
class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.string :gstn
      t.decimal :gst_percent, precision: 5, scale: 2
      t.decimal :loading_charges, precision: 12, scale: 2
      t.references :updated_by, foreign_key: { to_table: :admins }

      t.timestamps
    end

    add_index :settings, "(true)", unique: true, name: "index_settings_singleton"
  end
end
