module ApplicationHelper
  def row_class(product)
    return 'parent' if product.is_parent?
    return 'variant' if product.is_variant?
  end
end
