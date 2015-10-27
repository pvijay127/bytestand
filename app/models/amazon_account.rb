class AmazonAccount < ActiveRecord::Base
  has_many :amazon_products, class_name: 'Product', dependent: :destroy
  belongs_to :shop
  # I removed the uniqueness validation because I expect two stores to 
  # be related to the same amazon account.
  validates :merchant_id, :auth_token, presence: true #, uniqueness: true
  validates :marketplace_id, presence: true

  def api_keys
    @api_keys ||= {
      merchant_id: merchant_id,
      marketplace_id: marketplace_id,
      auth_token: auth_token
    }
  end
end

# == Schema Information
# Schema version: 20151008161652
#
# Table name: amazon_accounts
#
#  auth_token     :string
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  marketplace_id :string
#  merchant_id    :string
#  shop_id        :integer          indexed
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_amazon_accounts_on_shop_id  (shop_id)
#
