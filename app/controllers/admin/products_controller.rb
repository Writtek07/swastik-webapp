# Catalogue view for the admin console. Every role can browse products and
# their price history; only super users can change a product's details.
class Admin::ProductsController < Admin::BaseController
  # Fields a super user may edit. `slug` and `key` are left out on purpose: the
  # slug is the public URL and the key ties the product to its category filter
  # and enquiry links, so changing either would break links in the wild.
  EDITABLE_ATTRIBUTES = %i[
    title eyebrow category summary description image_url position has_guage_price
    tags_text sizes_text applications_text specs_text
  ].freeze

  require_role :super_user, only: %i[edit update]

  before_action :set_product, only: %i[show edit update]

  def index
    @products = Product.ordered.includes(:daily_prices)
  end

  def show
    @pagy, @prices = pagy(@product.daily_prices.with_previous_price.recent.includes(:admin))
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: "#{@product.title} updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_product
    @product = Product.find_by!(slug: params[:id])
  end

  def product_params
    params.expect(product: EDITABLE_ATTRIBUTES)
  end
end
