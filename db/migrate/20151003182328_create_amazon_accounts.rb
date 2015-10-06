class CreateAmazonAccounts < ActiveRecord::Migration
  def change
    create_table :amazon_accounts do |t|
      t.belongs_to :shop, index: true, foreign_key: true
      t.string :seller_id
      t.string :marketplace_id
      t.string :mws_auth_token

      t.timestamps null: false
    end
  end
end
