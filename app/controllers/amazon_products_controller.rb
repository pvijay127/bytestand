class AmazonProductsController < AuthenticatedController
  before_action :activate_shopify_session, only: [:push]
  # PUT /amazon_products/pull
  def pull
    GetAmazonProductsJob.perform_later(amazon_account_id: current_shop.amazon_account.id)
    Tracker.start_tracking_pull(current_shop.amazon_account.api_keys[:merchant_id])
    @notice = "Pulling your products from amazon. this will take some minutes. please be patient."
    respond_to do |format|
      format.js 
    end
  end

  def push
    if params[:all]
      push_all
    else
      push_selected
    end
    respond_to do |format|
      format.js
    end
  end

  def search
    puts "333333333"
    respond_to do |format|
      format.js
    end
  end

  helper_method :notice, :pulling_amazon_products?, :products, :product_search
  private
  def notice
    @notice
  end

  def products
    return @products if @products
    product_search.search
    @products = product_search.results(page: params[:page], per: params[:product_displayed])
  end

  def product_search
    @product_search ||= ProductSearch.new(query: params[:query])
  end

  def activate_shopify_session
    # sess = ShopifyAPI::Session.new(current_shop.domain, current_shop.token)
    # ShopifyAPI::Base.activate_session(sess)
  end

  def push_selected
    @products = Product.where(id: params[:product_ids]).a_parent
    push_products
  end

  def push_all
    @products = Product.a_parent
    push_products
  end

  def push_products
    @products.find_each do|product|
      next if product.on_shopify?
      shopify_product = ShopifyAPI::Product.new(product.shopify_attrs)
      shopify_product.save
      product.set_ids(shopify_product)
    end
  end
end
