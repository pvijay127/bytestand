class Product < ActiveRecord::Base
  belongs_to :amazon_account
end

# == Schema Information
# Schema version: 20151008161652
#
# Table name: products
#
#  amazon_account_id :integer          indexed
#  asin              :string           not null
#  color             :string
#  compare_at_price  :string
#  created_at        :datetime         not null
#  description       :text
#  features          :text
#  id                :integer          not null, primary key
#  image             :text
#  package_height    :string
#  package_length    :string
#  package_width     :string
#  price             :string
#  product_type      :string
#  quantity          :integer
#  seller_sku        :string
#  size              :string
#  title             :string
#  updated_at        :datetime         not null
#  vendor            :string
#  weight            :string
#
# Indexes
#
#  index_products_on_amazon_account_id  (amazon_account_id)
#
