class CreateDailyPrices < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.references :admin, null: false, foreign_key: true
      t.date :priced_on, null: false
      t.decimal :price, precision: 12, scale: 2, null: false
      t.text :notes

      t.timestamps
    end

    add_index :daily_prices, [ :product_id, :priced_on ], unique: true
    add_index :daily_prices, :priced_on
  end
end
