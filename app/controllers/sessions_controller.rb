class SessionsController < ApplicationController
  include ShopifyApp::SessionsController
  after_action :create_app_uninstall_webhook, only: :callback

  private
  def create_app_uninstall_webhook
    if session[:shopify].present?
      sess = ShopifyAPI::Session.new(session['shopify_domain'], token)
      ShopifyAPI::Base.activate_session(sess)
      webhook = ShopifyAPI::Webhook.create(address: uninstall_app_url, topic: 'app/uninstalled', format: 'json')
      Shop.where(domain: session['shopify_domain']).update_all(webhook_id: webhook.id)
    end
  end
  
  def token
    request.env['omniauth.auth']['credentials']['token']
  end

end
