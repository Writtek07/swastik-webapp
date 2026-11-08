class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :slug, null: false
      t.string :key, null: false
      t.string :category, null: false
      t.string :title, null: false
      t.string :eyebrow
      t.text :summary
      t.text :description
      t.string :visual
      t.string :accent
      t.string :image_url
      t.string :tags, array: true, default: [], null: false
      t.string :sizes, array: true, default: [], null: false
      t.string :applications, array: true, default: [], null: false
      t.jsonb :specs, default: [], null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :key
    add_index :products, :position
  end
end
