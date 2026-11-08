# Static content source for the marketing site.
#
# Everything the public pages render lives here so the views stay declarative and
# the data can later be swapped for ActiveRecord tables or a CMS without touching
# the templates. Values are plain Ruby hashes with symbol keys.
module Catalog
  # Reads a company setting from ENV, falling back to the default when the
  # variable is unset or blank. Values are read once at boot, so restart the app
  # after changing them. See docs/seo.md for the full list.
  def self.env(name, default = nil)
    ENV[name].presence || default
  end

  # Structured postal address, used for the visible address line and the
  # LocalBusiness structured data.
  ADDRESS = {
    street: env("COMPANY_STREET", "Industrial Area"),
    locality: env("COMPANY_CITY", "Raipur"),
    region: env("COMPANY_REGION", "Chhattisgarh"),
    region_code: env("COMPANY_REGION_CODE", "IN-CT"),
    postal_code: env("COMPANY_POSTAL_CODE", "492001"),
    country: env("COMPANY_COUNTRY", "India"),
    country_code: env("COMPANY_COUNTRY_CODE", "IN"),
    latitude: env("COMPANY_LATITUDE"),
    longitude: env("COMPANY_LONGITUDE")
  }.freeze

  COMPANY = {
    name: env("COMPANY_NAME", "Swastik Enterprise"),
    legal_name: env("COMPANY_LEGAL_NAME", "Swastik Enterprise Steel & Structural Solutions"),
    tagline: env("COMPANY_TAGLINE", "Iron & steel, engineered for the long haul"),
    established: env("COMPANY_ESTABLISHED", "1988").to_i,
    summary: env("COMPANY_SUMMARY",
                 "A steel manufacturing and supply house serving infrastructure, industrial, " \
                 "fabrication and construction teams across Central India."),
    phone: env("COMPANY_PHONE", "+91 98261 00000"),
    phone_alt: env("COMPANY_PHONE_ALT", "+91 771 222 5151"),
    email: env("COMPANY_EMAIL", "sales@swastikenterprise.example"),
    address: env("COMPANY_ADDRESS",
                 "#{ADDRESS[:street]}, #{ADDRESS[:locality]}, #{ADDRESS[:region]} #{ADDRESS[:postal_code]}, #{ADDRESS[:country]}"),
    # Languages the sales desk answers in, comma-separated.
    languages: env("COMPANY_LANGUAGES", "English,Hindi").split(",").map(&:strip),
    hours: env("COMPANY_HOURS", "Mon – Sat, 9:30 am – 6:30 pm IST"),
    # Machine-readable hours for structured data: comma-separated schema.org
    # day names plus 24-hour open/close times.
    open_days: env("COMPANY_OPEN_DAYS", "Monday,Tuesday,Wednesday,Thursday,Friday,Saturday").split(",").map(&:strip),
    opens: env("COMPANY_OPENS", "09:30"),
    closes: env("COMPANY_CLOSES", "18:30"),
    map_url: env("COMPANY_MAP_URL",
                 "https://maps.google.com/?q=#{ERB::Util.url_encode("#{ADDRESS[:street]} #{ADDRESS[:locality]} #{ADDRESS[:region]}")}"),
    # Areas served, comma-separated; feeds `areaServed` in structured data.
    area_served: env("COMPANY_AREA_SERVED",
                     "Chhattisgarh,Madhya Pradesh,Maharashtra,Odisha,Jharkhand,Uttar Pradesh").split(",").map(&:strip),
    social: [
      { label: "LinkedIn", url: env("COMPANY_LINKEDIN_URL", "https://www.linkedin.com/") },
      { label: "Instagram", url: env("COMPANY_INSTAGRAM_URL", "https://www.instagram.com/") },
      { label: "Facebook", url: env("COMPANY_FACEBOOK_URL", "https://www.facebook.com/") },
      { label: "YouTube", url: env("COMPANY_YOUTUBE_URL") },
      { label: "X", url: env("COMPANY_X_URL") }
    ].select { |social| social[:url] }.map(&:freeze).freeze
  }.freeze

  # Social profiles that point at an actual page rather than a network's home
  # page; only these are published as `sameAs` in structured data.
  def self.social_profiles
    COMPANY[:social].map { |social| social[:url] }.select { |url| profile_url?(url) }
  end

  def self.profile_url?(url)
    URI(url).path.to_s.delete("/").present?
  rescue URI::InvalidURIError
    false
  end

  # Headline numbers. `suffix` is appended verbatim, `value` drives the count-up.
  STATS = [
    { value: 35, suffix: "+", label: "Years in steel", note: "Trading, rolling and supply since 1988" },
    { value: 12, suffix: "L+", label: "Tonnes dispatched", note: "Across structural, flat and reinforcement steel" },
    { value: 480, suffix: "+", label: "Projects supplied", note: "Infrastructure, industrial and commercial" },
    { value: 96, suffix: "%", label: "On-time delivery", note: "Measured against committed dispatch dates" }
  ].freeze

  VALUES = [
    {
      key: "trust",
      title: "Trust",
      body: "Everyone who works with us does what is right for the client, the business and each other.",
      icon: "handshake"
    },
    {
      key: "empowerment",
      title: "Empowerment",
      body: "Our teams are enabled to make decisions that move a client's project forward without waiting.",
      icon: "spark"
    },
    {
      key: "commitment",
      title: "Commitment",
      body: "We deliver what we promise — on specification, on quantity and on the agreed date.",
      icon: "check"
    },
    {
      key: "responsibility",
      title: "Social responsibility",
      body: "We strictly discourage and condemn child labour and the use of conflict minerals.",
      icon: "shield"
    },
    {
      key: "safety",
      title: "Health & safety",
      body: "An organisation cannot succeed at the cost of ignoring people's health and safety at work.",
      icon: "helmet"
    },
    {
      key: "environment",
      title: "Environment",
      body: "We actively work to reduce, reuse and recycle waste across our plants and yards.",
      icon: "leaf"
    }
  ].freeze

  MILESTONES = [
    { year: "1988", title: "Founded in Raipur", body: "Started as an iron and steel trading house supplying local fabricators." },
    { year: "1996", title: "First rolling capacity", body: "Commissioned re-rolling capacity for structural sections and flats." },
    { year: "2004", title: "Reinforcement steel", body: "Added TMT reinforcement manufacturing with in-house quality control." },
    { year: "2012", title: "Tubes & pipes", body: "Expanded into ERW tubes, MS pipes and hollow sections." },
    { year: "2019", title: "Project supply desk", body: "Dedicated project desk for infrastructure and EPC material schedules." },
    { year: "2024", title: "Digital ordering", body: "Enquiry-to-dispatch tracking for repeat and project accounts." }
  ].freeze

  # Ordered process used on the Plant & Facility page.
  PROCESS = [
    { step: "01", title: "Raw material intake", body: "Scrap and sponge iron are graded, weighed and logged before charging.", icon: "intake" },
    { step: "02", title: "Melting & refining", body: "Induction furnaces melt to chemistry, with ladle refining to hit the target grade.", icon: "furnace" },
    { step: "03", title: "Casting", body: "Continuous casting produces billets and blooms to the required section.", icon: "casting" },
    { step: "04", title: "Rolling", body: "Reheating and rolling mills form beams, channels, angles, flats and bars.", icon: "rolling" },
    { step: "05", title: "Testing & certification", body: "Tensile, bend, chemistry and dimensional checks with mill test certificates.", icon: "lab" },
    { step: "06", title: "Dispatch & logistics", body: "Cut-to-length, bundling, tagging and coordinated dispatch to site.", icon: "truck" }
  ].freeze

  CAPABILITIES = [
    { title: "Specification-led sourcing", body: "Browse by family, section and size, then send the exact schedule you need quoted.", icon: "ruler" },
    { title: "Cut-to-length & fabrication", body: "Sections cut, drilled and bundled to drawing before they leave the yard.", icon: "saw" },
    { title: "Mill test certification", body: "Chemistry and mechanical test certificates issued with every dispatch.", icon: "certificate" },
    { title: "Project scheduling", body: "Staged releases against your construction programme instead of one bulk drop.", icon: "calendar" },
    { title: "Logistics coordination", body: "Full-load and part-load dispatch across Central India and beyond.", icon: "truck" },
    { title: "Repeat-order accounts", body: "Stored specifications and pricing so reordering takes one phone call.", icon: "repeat" }
  ].freeze

  # `image` is an Unsplash photo id (images.unsplash.com/photo-<id>) chosen to
  # show the sector the card describes; `visual` is the SVG plate used as a
  # fallback when no photo is set.
  APPLICATIONS = [
    { title: "Industrial structures", body: "Plant sheds, equipment frames and heavy fabrication.", visual: "beam",
      image: "1496247749665-49cf5b1022e9", alt: "Steel-framed heavy industrial plant interior with overhead crane hooks" },
    { title: "Infrastructure & bridges", body: "Reinforcement and structural steel for public works.", visual: "rebar",
      image: "1645969024085-6ede0fcc5580", alt: "Steel truss road bridge against a clear blue sky" },
    { title: "Commercial construction", body: "Framing, columns and reinforcement for buildings.", visual: "column",
      image: "1527335988388-b40ee248d80c", alt: "High-rise steel building frame under construction beside tower cranes" },
    { title: "Fabrication & engineering", body: "Flats, angles and hollow sections for workshops.", visual: "angle",
      image: "1744735973756-b2efa8be24c8", alt: "Welder joining steel sections in a fabrication workshop, sparks flying" }
  ].freeze

  CLIENTS = [
    { name: "State Infrastructure Board", sector: "Government" },
    { name: "Central PWD Circle", sector: "Government" },
    { name: "NHAI Project Packages", sector: "Infrastructure" },
    { name: "Bharat Heavy Fabricators", sector: "Industrial" },
    { name: "Raipur Steel Structures", sector: "Fabrication" },
    { name: "Chhattisgarh Housing Board", sector: "Government" },
    { name: "Vindhya Engineering Works", sector: "Industrial" },
    { name: "Mahanadi Bridge Consortium", sector: "Infrastructure" }
  ].freeze

  APPROVALS = [
    "ISO 9001:2015 quality management",
    "BIS licensed reinforcement steel",
    "RDSO approved supplier categories",
    "State PWD registered vendor",
    "MSME registered enterprise",
    "GST compliant pan-India dispatch"
  ].freeze

  FAQS = [
    {
      question: "What is the minimum order quantity?",
      answer: "We supply from a single bundle for stocked sections up to full rakes for project schedules. " \
              "Tell us the section, grade and quantity and we will confirm the most economical dispatch."
    },
    {
      question: "Do you provide mill test certificates?",
      answer: "Yes. Every dispatch carries a mill test certificate covering chemistry, tensile strength, yield " \
              "strength and elongation, along with dimensional inspection records."
    },
    {
      question: "Can you cut sections to length?",
      answer: "Cut-to-length, drilling and bundling to drawing are available on structural sections, flats and " \
              "pipes. Share the cutting list with your enquiry."
    },
    {
      question: "How quickly can you quote?",
      answer: "Stocked sections are usually quoted the same working day. Project schedules with mixed sections " \
              "and staged delivery are quoted within 24 to 48 hours."
    },
    {
      question: "Which regions do you deliver to?",
      answer: "Chhattisgarh, Madhya Pradesh, Maharashtra, Odisha, Jharkhand and Uttar Pradesh are routine. " \
              "Other states are served on full-load dispatch."
    }
  ].freeze


  # Navigation is data-driven so the navbar, mega menu, mobile drawer and footer
  # all stay in sync from one place.
  NAV = [
    { label: "Home", path: :root_path },
    {
      label: "About",
      path: :about_path,
      children: [
        { label: "Who we are", path: :about_path, description: "Our history, values and leadership" },
        { label: "Plant & facility", path: :plant_path, description: "Melting, rolling and testing" },
        { label: "Clients & approvals", path: :clients_path, description: "Who we supply and how we qualify" }
      ]
    },
    {
      label: "Products",
      path: :products_path,
      children: :product_children
    },
    { label: "Plant & Facility", path: :plant_path },
    { label: "Clients", path: :clients_path },
    { label: "Contact", path: :contact_path }
  ].freeze

  # Product families live in the `products` table (see db/seeds.rb). These
  # readers stay on Catalog so the navbar, footer and enquiry form keep a single
  # entry point for site content.
  def self.product(slug)
    Product.find_by(slug: slug)
  end

  # Looks up a family by its category key (the value the enquiry form submits).
  def self.product_by_key(key)
    Product.find_by(key: key)
  end

  # Human-readable family name for a category key, or nil when unknown.
  def self.category_name(key)
    product_by_key(key)&.category
  end

  def self.categories
    Product.categories
  end

  def self.products_for(key)
    Product.products_for(key)
  end

  def self.nav_children(entry)
    return entry[:children] unless entry[:children] == :product_children

    Product.ordered.map do |product|
      { label: product.title, path: [ :product_path, product.slug ], description: product.summary }
    end
  end
end
