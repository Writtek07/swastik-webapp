class CreateEnquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :enquiries do |t|
      t.string :name
      t.string :company
      t.string :email
      t.string :phone
      t.string :product_key
      t.string :quantity
      t.string :delivery_location
      t.text :message
      t.string :status, null: false, default: "new"

      t.timestamps
    end

    add_index :enquiries, :status
    add_index :enquiries, :created_at
  end
end
