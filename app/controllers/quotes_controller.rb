# "Get your quote" on the home page: prices one product size at a quantity and
# sends the quotation back as a PDF download. Nothing is stored.
class QuotesController < ApplicationController
  rate_limit to: 20, within: 10.minutes, only: :create,
             with: -> {
               track_event "quote_error", reason: "rate_limited"
               redirect_to root_path(anchor: "quote"), alert: "Too many quotes in a short time. Please try again in a few minutes."
             }

  def create
    quote = QuoteCalculator.new(product_id: quote_params[:product_id], size: quote_params[:size],
                                quantity: quote_params[:quantity]).call
    send_data QuotePdf.new(quote).render, filename: "#{quote.number}.pdf", type: "application/pdf", disposition: "attachment"
  rescue QuoteCalculator::Error => e
    track_event "quote_error", reason: e.message
    redirect_to root_path(anchor: "quote"), alert: e.message
  end

  private

  def quote_params
    params.fetch(:quote, {}).permit(:product_id, :size, :quantity)
  end
end
