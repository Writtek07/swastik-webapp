class AddHasGuagePriceToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :has_guage_price, :boolean, default: false, null: false
  end
end
