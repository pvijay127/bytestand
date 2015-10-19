class Product < ActiveRecord::Base
  belongs_to :amazon_account
  belongs_to :parent, class_name: 'Product'
  has_many :variants, class_name: 'Product', foreign_key: :parent_id
  scope :a_parent, -> { where(is_parent: true) }
  scope :a_variant, -> { where.not(parent_id: nil) }

  def amazon_url
    "http://www.amazon.com/gp/product/#{asin}"
  end

  def is_parent?
    is_parent
  end

  def is_variant?
    parent_id.present?
  end

  def shopify_attrs
    @shopify_attrs ||= {
      title: title,
      body_html: description,
      variants: variants_attributes,
      options: shopify_options
    }
  end

  def shopify_options
    shopify_options = []
    shopify_options.push({ name: 'Size', position: 1, values: sizes }) if multiple_sizes?
    shopify_options.push({ name: 'Color', position: 2, values: colors }) if multiple_colors?
    shopify_options
  end

  def variants_attributes
    @variants_attributes ||= variants.to_a.unshift(self).map do |variant|
      {
        price: variant.price,
        compare_at_price: compare_at_price,
        option1: variant.size,
        option2: variant.color,
        # option3: variant.material, # this is not available right now
        sku: variant.seller_sku,
        inventory_quantity: quantity.to_i,
        grams: variant.grams,
        weight: variant.weight_in_kg,
        weight_unit: 'kg'
      }
    end
  end

  def set_ids(shopify_product)
    self.shopify_id = shopify_product.id
    set_variants_ids(shopify_product.variants.map(&:id)[1..-1])
    save
  end

  def set_variants_ids(shopify_ids)
    shopify_ids.each_with_index do |id, idx|
      variants[idx].update_attributes(shopify_id: id)
    end
  end

  def on_shopify?
    ShopifyAPI::Product.exists?(shopify_id)
  end

  def grams
    return 0.0 unless weight
    @grams ||= weight.split.first.to_f * 453.592
  end

  def weight_in_kg
    @weight_in_kg ||= grams / 1000
  end

  def self.set_products_parents
    where.not(parent_asin: nil).pluck(:parent_asin).each do |pasin|
      # find the first product that its asin is pasin, this means its the
      # parent. If it does not exist, we should take the first one between variants
      # and make it the parent
      variants_ids = where("products.asin = :pasin OR products.parent_asin = :pasin", pasin: pasin).pluck(:id)
      pid = variants_ids.first
      if variants_ids.count > 1
        # Set is_parent to true for the parent, this is required to ease 
        # manipulation on the interface
        where(id: pid).update_all(is_parent: true)
      end
      # Set parent_id of all variants except the parent itself
      where.not(id: pid).where(parent_asin: pasin).update_all(parent_id: pid)
    end
  end

  private
  def colors
    @colors ||= variants.pluck(:color).push(self.color).uniq.sort
  end

  def multiple_colors?
    colors.count > 1
  end

  def sizes
    @sizes ||= variants.pluck(:size).push(self.size).uniq.sort
  end

  def multiple_sizes?
    sizes.count > 1
  end
end

# == Schema Information
# Schema version: 20151016103831
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
#  is_parent         :boolean          default(FALSE)
#  package_height    :string
#  package_length    :string
#  package_width     :string
#  parent_asin       :string
#  parent_id         :integer
#  price             :string
#  product_type      :string
#  quantity          :integer
#  seller_sku        :string
#  shopify_id        :string
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
