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
    product_path(product.slug)
  end

  def enquiry_product_options
    Product.ordered.map { |product| [ "#{product.title} — #{product.category}", product.key ] }.uniq
  end

  # Sized Unsplash URL for a Catalog photo id.
  def unsplash_url(id, width: 1200, height: nil)
    params = { auto: "format", fit: "crop", w: width, h: height, q: 70 }.compact
    "https://images.unsplash.com/photo-#{id}?#{params.to_query}"
  end

  # The horizontal logo (mark + wordmark). The "ENTERPRISE" line is black in the
  # original artwork, so dark surfaces need the variant with light lettering:
  # `on: :dark` for always-dark areas, `on: :auto` to follow the site theme.
  # Assets are generated from the source logo; regenerate them with script/brand/build.
  LOCKUP_SIZE = { width: 679, height: 120 }.freeze

  def brand_lockup(on: :auto, css: "h-10 w-auto")
    name = Catalog::COMPANY[:name]
    dark = image_tag("brand/lockup-dark.webp", alt: name, **LOCKUP_SIZE,
                     class: [ css, ("hidden dark:block" if on == :auto) ])
    return dark if on == :dark

    light = image_tag("brand/lockup-light.webp", alt: name, **LOCKUP_SIZE,
                      class: [ css, ("dark:hidden" if on == :auto) ])
    on == :auto ? safe_join([ light, dark ]) : light
  end

  # The symbol on its own, for tight spots (admin chrome, the intro).
  def brand_mark(css: "h-10 w-auto", alt: "")
    image_tag("brand/mark.webp", alt: alt, width: 320, height: 232, class: css)
  end

  def current_year
    Time.current.year
  end
end
