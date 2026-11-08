class PagesController < ApplicationController
  # Families shown as image tiles on the home page; the full set lives on the
  # catalogue. Any slug that goes missing is backfilled from the catalogue order.
  FEATURED_SLUGS = %w[parallel-flange-beams tmt-rebars tubes-and-pipes].freeze

  def home
    @stats = Catalog::STATS
    @capabilities = Catalog::CAPABILITIES
    @applications = Catalog::APPLICATIONS
    @featured_products = featured_products
    @process = Catalog::PROCESS
    @clients = Catalog::CLIENTS
    @faqs = Catalog::FAQS
    @quotable = QuoteCalculator.quotable
  end

  def about
    @values = Catalog::VALUES
    @milestones = Catalog::MILESTONES
    @stats = Catalog::STATS
  end

  def plant
    @process = Catalog::PROCESS
    @capabilities = Catalog::CAPABILITIES
  end

  def clients
    @clients = Catalog::CLIENTS
    @approvals = Catalog::APPROVALS
    @applications = Catalog::APPLICATIONS
  end

  def contact
    @faqs = Catalog::FAQS
  end

  private

  def featured_products
    featured = Product.where(slug: FEATURED_SLUGS).index_by(&:slug).values_at(*FEATURED_SLUGS).compact
    featured + Product.ordered.where.not(id: featured.map(&:id)).limit(FEATURED_SLUGS.size - featured.size)
  end
end
