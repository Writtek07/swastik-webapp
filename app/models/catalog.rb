# Static content source for the marketing site.
#
# Everything the public pages render lives here so the views stay declarative and
# the data can later be swapped for ActiveRecord tables or a CMS without touching
# the templates. Values are plain Ruby hashes with symbol keys.
module Catalog
  COMPANY = {
    name: "Swastik Enterprise",
    legal_name: "Swastik Enterprise Steel & Structural Solutions",
    tagline: "Iron & steel, engineered for the long haul",
    established: 1988,
    summary: "A steel manufacturing and supply house serving infrastructure, industrial, " \
             "fabrication and construction teams across Central India.",
    phone: "+91 98261 00000",
    phone_alt: "+91 771 222 5151",
    email: "sales@swastikenterprise.example",
    address: "Industrial Area, Raipur, Chhattisgarh 492001, India",
    hours: "Mon – Sat, 9:30 am – 6:30 pm IST",
    map_url: "https://maps.google.com/?q=Industrial+Area+Raipur+Chhattisgarh",
    social: [
      { label: "LinkedIn", url: "https://www.linkedin.com/" },
      { label: "Instagram", url: "https://www.instagram.com/" },
      { label: "Facebook", url: "https://www.facebook.com/" }
    ]
  }.freeze

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

  APPLICATIONS = [
    { title: "Industrial structures", body: "Plant sheds, equipment frames and heavy fabrication.", visual: "beam" },
    { title: "Infrastructure & bridges", body: "Reinforcement and structural steel for public works.", visual: "rebar" },
    { title: "Commercial construction", body: "Framing, columns and reinforcement for buildings.", visual: "column" },
    { title: "Fabrication & engineering", body: "Flats, angles and hollow sections for workshops.", visual: "angle" }
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

  # Product families. `visual` selects the SVG blueprint partial, `accent` the
  # colour treatment, and `sizes` the specification table on the detail page.
  PRODUCTS = [
    {
      slug: "parallel-flange-beams",
      key: "structures",
      category: "Concrete Structures",
      title: "Parallel Flange Beams & Columns",
      eyebrow: "Structural steel",
      summary: "Heavy-duty beams and columns for industrial frames, building structures and infrastructure projects.",
      description: "Rolled parallel flange sections with consistent web and flange thickness, used as primary " \
                   "beams, columns and crane gantry girders. Supplied cut to length with mill test certification.",
      visual: "beam",
      accent: "ember",
      tags: [ "Beams", "Columns", "Project supply" ],
      sizes: [ "100 × 50", "125 × 70", "150 × 75", "175 × 85", "200 × 100", "250 × 125", "300 × 150" ],
      specs: [
        [ "Grade", "IS 2062 E250 / E350" ],
        [ "Length", "6 m – 12 m, cut to order" ],
        [ "Standard", "IS 12778 / IS 808" ],
        [ "Finish", "Mill finish, primer on request" ]
      ],
      applications: [ "Industrial sheds", "Crane gantries", "Multi-storey frames", "Equipment supports" ]
    },
    {
      slug: "channels",
      key: "structures",
      category: "Concrete Structures",
      title: "Channels",
      eyebrow: "Structural steel",
      summary: "Reliable rolled channels for frames, supports, fabrication and industrial applications.",
      description: "Hot rolled MS channels with parallel or tapered flanges, used for purlins, bracing, " \
                   "machine bases and general fabrication work.",
      visual: "channel",
      accent: "steel",
      tags: [ "Channels", "Fabrication", "Industrial" ],
      sizes: [ "75 × 40", "100 × 50", "125 × 65", "150 × 75", "200 × 75", "250 × 80" ],
      specs: [
        [ "Grade", "IS 2062 E250" ],
        [ "Length", "6 m – 12 m" ],
        [ "Standard", "IS 808" ],
        [ "Finish", "Mill finish" ]
      ],
      applications: [ "Purlins", "Bracing", "Machine bases", "Trailer chassis" ]
    },
    {
      slug: "angles",
      key: "structures",
      category: "Concrete Structures",
      title: "Angles",
      eyebrow: "Structural steel",
      summary: "Equal and unequal angle sections for bracing, frames, supports and general fabrication.",
      description: "Rolled equal and unequal angles with clean edges and consistent thickness, suited to " \
                   "bracing, transmission structures, shelving and general engineering.",
      visual: "angle",
      accent: "ember",
      tags: [ "Equal angles", "Bracing", "Fabrication" ],
      sizes: [ "20 × 20", "25 × 25", "30 × 30", "40 × 40", "50 × 50", "65 × 65", "75 × 75", "100 × 100" ],
      specs: [
        [ "Grade", "IS 2062 E250" ],
        [ "Length", "6 m – 12 m" ],
        [ "Standard", "IS 808" ],
        [ "Finish", "Mill finish" ]
      ],
      applications: [ "Transmission towers", "Bracing", "Shelving", "Gates & grills" ]
    },
    {
      slug: "ms-flat",
      key: "structures",
      category: "Concrete Structures",
      title: "M.S. Flat",
      eyebrow: "Flat steel",
      summary: "Mild steel flats for fabrication, base plates, frames and engineering work.",
      description: "Rolled mild steel flats in a wide width range, supplied in standard lengths or cut to " \
                   "your cutting list for base plates, brackets and frames.",
      visual: "flat",
      accent: "steel",
      tags: [ "MS flat", "Cut-to-length", "Fabrication" ],
      sizes: [ "25 mm", "40 mm", "50 mm", "65 mm", "75 mm", "100 mm", "125 mm", "150 mm" ],
      specs: [
        [ "Grade", "IS 2062 E250" ],
        [ "Thickness", "3 mm – 25 mm" ],
        [ "Length", "6 m standard, cut to order" ],
        [ "Finish", "Mill finish" ]
      ],
      applications: [ "Base plates", "Brackets", "Frames", "General fabrication" ]
    },
    {
      slug: "ms-square-round",
      key: "structures",
      category: "Concrete Structures",
      title: "M.S. Square & Round",
      eyebrow: "Bar sections",
      summary: "Round and square mild steel sections suitable for machining, fabrication and general engineering.",
      description: "Bright and mill finish round and square bars for machining, shafts, pins, grills and " \
                   "general engineering applications.",
      visual: "round",
      accent: "ember",
      tags: [ "Round", "Square", "Engineering" ],
      sizes: [ "10 mm", "12 mm", "16 mm", "20 mm", "25 mm", "32 mm", "40 mm", "50 mm" ],
      specs: [
        [ "Grade", "IS 2062 / EN8 on request" ],
        [ "Length", "3 m – 6 m" ],
        [ "Finish", "Mill or bright" ],
        [ "Tolerance", "As per IS 1732" ]
      ],
      applications: [ "Machined parts", "Shafts & pins", "Grills", "Fencing" ]
    },
    {
      slug: "tmt-rebars",
      key: "tmt",
      category: "TMT & Reinforcement",
      title: "TMT Rebars",
      eyebrow: "Reinforcement steel",
      summary: "Deformed reinforcement bars designed for strength, bond and dependable performance in concrete structures.",
      description: "Thermo-mechanically treated reinforcement bars with a ribbed surface for superior bond " \
                   "strength, supplied in standard 12 m lengths and cut-to-length bundles.",
      visual: "rebar",
      accent: "ember",
      tags: [ "Fe 500D", "Rebar", "Infrastructure" ],
      sizes: [ "8 mm", "10 mm", "12 mm", "16 mm", "20 mm", "25 mm", "32 mm" ],
      specs: [
        [ "Grade", "Fe 500 / Fe 500D / Fe 550D" ],
        [ "Length", "12 m standard" ],
        [ "Standard", "IS 1786" ],
        [ "Certification", "Mill test certificate with every lot" ]
      ],
      applications: [ "RCC frames", "Bridges & flyovers", "Foundations", "Industrial flooring" ]
    },
    {
      slug: "tubes-and-pipes",
      key: "pipes",
      category: "Tubes & Pipes",
      title: "Tubes & Pipes",
      eyebrow: "ERW sections",
      summary: "Round, square and rectangular tube sections for construction, fencing, machinery and fabrication.",
      description: "ERW welded round, square and rectangular hollow sections with uniform wall thickness, " \
                   "used across structural, mechanical and architectural work.",
      visual: "pipe",
      accent: "steel",
      tags: [ "Round", "Square", "Rectangular" ],
      sizes: [ "3/4 in", "1 in", "1 1/4 in", "1 1/2 in", "2 in", "2 1/2 in", "3 in" ],
      specs: [
        [ "Grade", "IS 4923 YST 210 / 240" ],
        [ "Wall thickness", "1.6 mm – 6 mm" ],
        [ "Length", "6 m standard" ],
        [ "Finish", "Black, galvanised on request" ]
      ],
      applications: [ "Structural frames", "Fencing & gates", "Furniture", "Machinery guards" ]
    },
    {
      slug: "sheets-and-plates",
      key: "sheets",
      category: "Steel Sheets & Plates",
      title: "Sheets & Plates",
      eyebrow: "Flat steel",
      summary: "Steel sheets and plates for structural fabrication, industrial components and project requirements.",
      description: "Hot rolled sheets and plates in a range of thicknesses, supplied sheared or flame cut to " \
                   "your drawing for base plates, gussets and tank work.",
      visual: "plate",
      accent: "ember",
      tags: [ "Sheets", "Plates", "Fabrication" ],
      sizes: [ "2 mm+", "3 mm+", "5 mm+", "6 mm+", "8 mm+", "10 mm+", "12 mm+" ],
      specs: [
        [ "Grade", "IS 2062 E250 / E350" ],
        [ "Thickness", "2 mm – 40 mm" ],
        [ "Size", "1250 × 2500, 1500 × 6000" ],
        [ "Cutting", "Sheared or flame cut to drawing" ]
      ],
      applications: [ "Base plates", "Gussets", "Tanks & hoppers", "Structural fabrication" ]
    },
    {
      slug: "ms-pipes",
      key: "ms-pipes",
      category: "MS Pipes",
      title: "MS Pipes",
      eyebrow: "Mild steel",
      summary: "Mild steel pipes for structural, utility, scaffolding, fencing and general engineering applications.",
      description: "Mild steel pipes in nominal bore and outside diameter sizes for water lines, structural " \
                   "columns, scaffolding and general utility work.",
      visual: "pipe",
      accent: "steel",
      tags: [ "MS pipe", "Utility", "Structural" ],
      sizes: [ "25 OD", "32 OD", "42 OD", "48 OD", "60 OD", "76 OD", "88 OD" ],
      specs: [
        [ "Grade", "IS 1239 Part 1" ],
        [ "Class", "Light, medium, heavy" ],
        [ "Length", "6 m standard" ],
        [ "Finish", "Black, painted on request" ]
      ],
      applications: [ "Water & utility lines", "Scaffolding", "Structural columns", "Fencing" ]
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

  def self.product(slug)
    PRODUCTS.find { |product| product[:slug] == slug }
  end

  # Looks up a family by its category key (the value the enquiry form submits).
  def self.product_by_key(key)
    PRODUCTS.find { |product| product[:key] == key }
  end

  # Human-readable family name for a category key, or nil when unknown.
  def self.category_name(key)
    product_by_key(key)&.fetch(:category)
  end

  def self.categories
    PRODUCTS.map { |product| [ product[:key], product[:category] ] }.uniq
  end

  def self.products_for(key)
    return PRODUCTS if key.blank? || key == "all"

    PRODUCTS.select { |product| product[:key] == key }
  end

  def self.nav_children(entry)
    return entry[:children] unless entry[:children] == :product_children

    PRODUCTS.map do |product|
      { label: product[:title], path: [ :product_path, product[:slug] ], description: product[:summary] }
    end
  end
end
