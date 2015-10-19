class HomeController < AuthenticatedController
  def index
  end

  helper_method :products
  private
  def products
    @products ||= paginated
  end

  def paginated
    shop_products.page(params[:page] || 1)
  end

  def shop_products
    current_shop.amazon_products.a_parent
  end
end
