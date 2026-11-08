# One gauge price per product size per session. `entered_by` is whoever first
# entered it and never changes; `updated_by` is whoever last changed it.
class CreateGuagePrices < ActiveRecord::Migration[8.1]
  def change
    create_table :guage_prices do |t|
      t.references :guage_session, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :size, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.references :entered_by, null: false, foreign_key: { to_table: :admins }
      t.references :updated_by, null: false, foreign_key: { to_table: :admins }

      t.timestamps
    end

    add_index :guage_prices, [ :guage_session_id, :product_id, :size ], unique: true, name: "index_guage_prices_uniqueness"
  end
end
