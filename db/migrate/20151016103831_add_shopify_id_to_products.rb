class AddShopifyIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :shopify_id, :string
  end
end
