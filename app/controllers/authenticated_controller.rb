class AuthenticatedController < ApplicationController
  before_action :login_again_if_different_shop
  around_filter :shopify_session
  before_action :amazon_account_set?
  layout ShopifyApp.configuration.embedded_app? ? 'embedded_app' : 'application'

  helper_method :pulling_amazon_products?
  protected
  def current_shop
    @current_shop ||= Shop.find(session[:shopify])
  end

  def amazon_account_set?
    unless current_shop.amazon_account.present?
      session[:previous_path] = request.fullpath
      redirect_to new_amazon_account_path
    end
  end

  def pulling_amazon_products?
    Tracker.pulling_amazon_products?(current_shop.amazon_account.api_keys[:merchant_id])
  end

end
