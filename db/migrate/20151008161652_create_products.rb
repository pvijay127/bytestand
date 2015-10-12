class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :asin, null: false
      t.string  :title
      t.string  :vendor
      t.text    :description
      t.text    :features
      t.string  :seller_sku
      t.string  :price
      t.integer :quantity
      t.string  :product_type
      t.string  :color
      t.text    :image
      t.string  :package_height
      t.string  :package_width
      t.string  :package_length
      t.string  :weight
      t.string  :size
      t.string  :compare_at_price
      t.belongs_to :amazon_account, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
