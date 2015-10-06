class AmazonAccount < ActiveRecord::Base
  belongs_to :shop
  validates :seller_id, :marketplace_id, :mws_auth_token, presence: true
end

# == Schema Information
# Schema version: 20151003182328
#
# Table name: amazon_accounts
#
#  created_at     :datetime         not null
#  id             :integer          not null, primary key
#  marketplace_id :string
#  mws_auth_token :string
#  seller_id      :string
#  shop_id        :integer          indexed
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_amazon_accounts_on_shop_id  (shop_id)
#
