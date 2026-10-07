# View helpers for the marketing site: navigation state, page metadata and the
# small formatting jobs the templates would otherwise repeat.
module SiteHelper
  # Resolves a Catalog::NAV entry into a real path. Entries store either a route
  # helper symbol or an array of [helper, argument].
  def nav_path(path)
    return "#" if path.blank?
    return send(path) if path.is_a?(Symbol)

    send(path.first, *path.drop(1))
  end

  # True when the current request belongs to the given nav entry, used to set
  # aria-current and highlight the active item.
  def nav_active?(entry)
    target = nav_path(entry[:path])
    return true if target == request.path

    # Keep the parent highlighted on nested pages (e.g. /products/tmt-rebars).
    entry[:children].present? && target != root_path && request.path.start_with?(target)
  end

  def page_title(title = nil)
    base = "#{Catalog::COMPANY[:name]} — #{Catalog::COMPANY[:tagline]}"
    title.present? ? "#{title} | #{Catalog::COMPANY[:name]}" : base
  end

  def page_description(description = nil)
    description.presence || Catalog::COMPANY[:summary]
  end

  # Splits a stat value into the digits the counter animates and the suffix it
  # appends, so "12L+" renders as 12 + "L+".
  def stat_parts(stat)
    [ stat[:value], stat[:suffix].to_s ]
  end

  def product_path_for(product)
    product_path(product[:slug])
  end

  def enquiry_product_options
    Catalog::PRODUCTS.map { |product| [ "#{product[:title]} — #{product[:category]}", product[:key] ] }.uniq
  end

  def current_year
    Time.current.year
  end
end
