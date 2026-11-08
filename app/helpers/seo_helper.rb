# Search, social and AI-crawler metadata for the marketing site.
#
# Pages set their title and description with `content_for :title` /
# `content_for :description` as before. Everything else is derived here and
# rendered once by `shared/_seo_meta` in the layout <head>:
#
#   * canonical URL, robots directives, Open Graph and Twitter cards
#   * a JSON-LD @graph holding the Organization, WebSite and WebPage nodes plus
#     any page-specific nodes added with `structured_data`
#
# Templates render before the layout, so helpers called from a view or partial
# (page_hero sets the breadcrumb) are visible by the time the <head> is built.
module SeoHelper
  DEFAULT_ROBOTS = "index, follow, max-image-preview:large, max-snippet:-1, max-video-preview:-1".freeze
  OG_IMAGE_PATH = "/og-image.png".freeze

  # The public origin, e.g. "https://www.example.com". SITE_URL pins it so
  # canonical URLs never point at a staging host or a bare IP; without it the
  # current request's origin is used.
  def site_url
    (ENV["SITE_URL"].presence || request.base_url).chomp("/")
  end

  def absolute_url(path_or_url)
    return path_or_url if path_or_url.to_s.match?(%r{\Ahttps?://})

    "#{site_url}#{path_or_url}"
  end

  # Query strings (filters, preselected form values) never change which page a
  # URL is, so the canonical is always the bare path.
  def canonical_url
    absolute_url(content_for(:canonical).presence || request.path)
  end

  def meta_robots
    content_for(:robots).presence || DEFAULT_ROBOTS
  end

  def og_image_url
    absolute_url(content_for(:og_image).presence || OG_IMAGE_PATH)
  end

  def og_type
    content_for(:og_type).presence || "website"
  end

  # The schema.org type of the current page's WebPage node.
  def page_type(type = nil)
    type ? (@seo_page_type = type) : (@seo_page_type || "WebPage")
  end

  # Records the breadcrumb trail for structured data. `items` is the page hero's
  # [[label, path]] list; Home is prepended and a nil path means "this page".
  def seo_breadcrumbs(items)
    @seo_breadcrumbs = [ [ "Home", root_path ] ] + items.map { |label, path| [ label, path || request.path ] }
  end

  # Adds a page-specific node (Product, FAQPage, ItemList…) to the JSON-LD graph.
  def structured_data(node)
    (@seo_nodes ||= []) << node
    nil
  end

  def structured_data_tag
    graph = [ organization_node, website_node, webpage_node, breadcrumb_node, *@seo_nodes ].compact
    tag.script(json_escape({ "@context" => "https://schema.org", "@graph" => graph }.to_json).html_safe,
               type: "application/ld+json")
  end

  def organization_id = "#{site_url}/#organization"
  def website_id = "#{site_url}/#website"
  def webpage_id = "#{canonical_url}#webpage"

  # Strips markup and squeezes whitespace so descriptions read cleanly in
  # snippets, then trims to the length search engines display.
  def meta_text(text, length: 160)
    # strip_tags returns entity-escaped text; unescape it so ERB and to_json
    # escape exactly once ("Tubes & Pipes", not "Tubes &amp;amp; Pipes").
    plain = CGI.unescapeHTML(strip_tags(text.to_s)).squish
    truncate(plain, length: length, separator: " ", omission: "…", escape: false)
  end

  private

  def organization_node
    company = Catalog::COMPANY
    address = Catalog::ADDRESS

    {
      "@type" => [ "Organization", "LocalBusiness" ],
      "@id" => organization_id,
      "name" => company[:name],
      "legalName" => company[:legal_name],
      "description" => company[:summary],
      "slogan" => company[:tagline],
      "url" => "#{site_url}/",
      "logo" => { "@type" => "ImageObject", "url" => absolute_url("/logo.png"), "width" => 600, "height" => 373 },
      "image" => absolute_url(OG_IMAGE_PATH),
      "foundingDate" => company[:established].to_s,
      "email" => company[:email],
      "telephone" => company[:phone].delete(" "),
      "taxID" => company_gstin,
      "address" => {
        "@type" => "PostalAddress",
        "streetAddress" => address[:street],
        "addressLocality" => address[:locality],
        "addressRegion" => address[:region],
        "postalCode" => address[:postal_code],
        "addressCountry" => address[:country_code]
      },
      "geo" => geo_node,
      "hasMap" => company[:map_url],
      "openingHoursSpecification" => {
        "@type" => "OpeningHoursSpecification",
        "dayOfWeek" => company[:open_days],
        "opens" => company[:opens],
        "closes" => company[:closes]
      },
      "areaServed" => company[:area_served].map { |name| { "@type" => "State", "name" => name } },
      "contactPoint" => [ company[:phone], company[:phone_alt] ].compact_blank.map do |phone|
        { "@type" => "ContactPoint", "telephone" => phone.delete(" "), "contactType" => "sales",
          "email" => company[:email], "areaServed" => address[:country_code], "availableLanguage" => company[:languages] }
      end,
      "knowsAbout" => Product.ordered.pluck(:title),
      "hasCredential" => Catalog::APPROVALS.map { |name| { "@type" => "EducationalOccupationalCredential", "name" => name } },
      "sameAs" => Catalog.social_profiles.presence
    }.compact
  end

  def geo_node
    address = Catalog::ADDRESS
    return if address[:latitude].blank? || address[:longitude].blank?

    { "@type" => "GeoCoordinates", "latitude" => address[:latitude].to_f, "longitude" => address[:longitude].to_f }
  end

  # The GSTIN saved on the admin Settings page, when there is one.
  def company_gstin
    Setting.pick(:gstn)
  rescue ActiveRecord::ActiveRecordError
    nil
  end

  def website_node
    {
      "@type" => "WebSite",
      "@id" => website_id,
      "url" => "#{site_url}/",
      "name" => Catalog::COMPANY[:name],
      "description" => Catalog::COMPANY[:summary],
      "inLanguage" => "en-IN",
      "publisher" => { "@id" => organization_id }
    }
  end

  def webpage_node
    {
      "@type" => page_type,
      "@id" => webpage_id,
      "url" => canonical_url,
      "name" => content_for(:title).presence || page_title,
      "description" => content_for(:description).presence || page_description,
      "inLanguage" => "en-IN",
      "isPartOf" => { "@id" => website_id },
      "about" => { "@id" => organization_id },
      "primaryImageOfPage" => { "@type" => "ImageObject", "url" => og_image_url },
      "breadcrumb" => (@seo_breadcrumbs ? { "@id" => "#{canonical_url}#breadcrumb" } : nil)
    }.compact
  end

  def breadcrumb_node
    return if @seo_breadcrumbs.blank?

    {
      "@type" => "BreadcrumbList",
      "@id" => "#{canonical_url}#breadcrumb",
      "itemListElement" => @seo_breadcrumbs.each_with_index.map do |(label, path), index|
        { "@type" => "ListItem", "position" => index + 1, "name" => label, "item" => absolute_url(path) }
      end
    }
  end
end
