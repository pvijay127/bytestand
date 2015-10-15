class Product < ActiveRecord::Base
  belongs_to :amazon_account
  belongs_to :parent, class_name: 'Product'
  has_many :variants, class_name: 'Product', foreign_key: :parent_id

  def amazon_url
    "http://www.amazon.com/gp/product/#{asin}"
  end

  def self.set_products_variants
    where.not(parent_asin: nil).pluck(:parent_asin).each do |pasin|
      pid = where("products.asin = :pasin OR products.parent_asin = :pasin", pasin: pasin)
        .pluck(:id).first
      where.not(id: pid).where(parent_asin: pasin).update_all(parent_id: pid)
    end
  end
end

# == Schema Information
# Schema version: 20151012191058
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
#  parent_asin       :string
#  parent_id         :integer
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
