class ProductsController < ApplicationController
  def index
    @categories = Catalog.categories
    @active_category = params[:category].presence
    @products = Catalog.products_for(@active_category)
  end

  def show
    @product = Catalog.product(params[:slug])
    return redirect_to products_path, alert: "That product family is not available." if @product.nil?

    @related = Catalog::PRODUCTS.reject { |product| product[:slug] == @product[:slug] }.first(3)
  end
end
