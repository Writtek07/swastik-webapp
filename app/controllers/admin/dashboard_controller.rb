# Landing page for the admin console: today's pricing progress at a glance.
class Admin::DashboardController < Admin::BaseController
  def show
    @date = Date.current
    @products = Product.ordered
    @prices = DailyPrice.for_date(@date).includes(:admin).index_by(&:product_id)
    @priced_count = @prices.size
    @total_count = @products.size
    @recent = DailyPrice.recent.includes(:product, :admin).limit(8)
  end
end
