class AppsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def uninstall
        if shop = Shop.find_by(webhook_id: params[:id])
            sess = ShopifyAPI::Session.new(shop.domain, shop.token)
            ShopifyAPI::Base.activate_session(sess)
            webhook = ShopifyAPI::Webhook.find(shop.webhook_id)
            webhook.destroy if webhook
            shop.destroy
        end
        head :ok
    end
end