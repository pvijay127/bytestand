class Shop < ActiveRecord::Base
  has_one :amazon_account, dependent: :destroy
  has_many :amazon_products, through: :amazon_account

  validates :domain, uniqueness: true
  class << self
    def store(session)
      where(domain: session.url).destroy_all
      shop = new(domain: session.url, token: session.token)
      shop.save!
      shop.id
    end

    def retrieve(id)
      if shop = find(id)
        ShopifyAPI::Session.new(shop.domain, shop.token)
      end
    end
  end
end

# == Schema Information
# Schema version: 20151021202030
#
# Table name: shops
#
#  created_at :datetime         not null
#  domain     :text             indexed
#  id         :integer          not null, primary key
#  token      :text
#  updated_at :datetime         not null
#  webhook_id :string
#
# Indexes
#
#  index_shops_on_domain  (domain)
#
