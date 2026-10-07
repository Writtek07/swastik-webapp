class PagesController < ApplicationController
  def home
    @stats = Catalog::STATS
    @values = Catalog::VALUES
    @capabilities = Catalog::CAPABILITIES
    @applications = Catalog::APPLICATIONS
    @featured_products = Catalog::PRODUCTS.first(6)
    @process = Catalog::PROCESS
    @clients = Catalog::CLIENTS
    @faqs = Catalog::FAQS
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
end
