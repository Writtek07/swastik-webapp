class ProductsController < ApplicationController
  def index
    @categories = Catalog.categories
    @active_category = params[:category].presence
    @products = Catalog.products_for(@active_category)
  end

  def show
    # A real 404 rather than a redirect, so search engines drop dead product
    # URLs instead of treating the catalogue as a soft 404.
    @product = Catalog.product(params[:slug]) or raise ActiveRecord::RecordNotFound

    @related = Product.where.not(id: @product.id).ordered.limit(3)
  end
end
