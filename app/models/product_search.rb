class ProductSearch 
  attr_accessor :query

  def initialize(query:)
    @query = query.downcase
  end

  def results(page: 0)
    if query.blank?
      @products.page(page)
    else
      @products.to_a.map! do |product|
        product.product_parent 
      end.uniq!(&:id)
      Kaminari.paginate_array(@products).page(page)
    end
  end

  def search(scope: Product)
    @products ||= if query.blank?
                    scope.all
                  else
                    scope.with_query(sql_query, "%#{query}%")
                  end
  end
  
  def sql_query 
    "lower(title) LIKE :query or lower(seller_sku) LIKE :query OR price LIKE :query"
  end

  def product_variants(product)
    search = ProductSearch.new(query: query)

    if product.is_variant?
      # if product is a parent, just return its variants that satisfies the 
      # query
      variants = search.search(scope: product.parent.variants)
    elsif product.is_parent?
      # if the product is a variant, just return its parent's variants that
      # satisfies the query
      variants = search.search(scope: product.variants)
    end
    variants ||= []
    exclude_products(variants)
    variants
  end

  def exclude_products(products)
    Array(products).map(&:id).each do |product_id|
      excluded_products.push(product_id)
    end
  end

  def excluded_products
    @excluded_products ||= []
  end

  def excluded_product?(product)
    excluded_products.include?(product.id) if query.present?
  end

end
