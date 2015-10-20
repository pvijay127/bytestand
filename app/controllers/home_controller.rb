class HomeController < AuthenticatedController
  def index
  end

  helper_method :products, :product_search
  private
  def products
    return @products if @products
    product_search.search(scope: current_shop.amazon_products)
    @products = product_search.results(page: params[:page])
  end

  def product_search
    @product_search ||= ProductSearch.new(query: '')
  end
end
