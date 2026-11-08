# Seeds the product catalogue.
#
# The product families used to live in `Catalog::PRODUCTS` as plain hashes.
# They are now rows in the `products` table, and this file is the canonical
# copy of that data — including the image URL each family is illustrated with.
#
# Idempotent: re-running updates existing rows by slug instead of duplicating
# them, so it is safe to run against an existing database.
#
#   bin/rails db:seed

PRODUCTS = [
  {
    slug: "parallel-flange-beams",
    key: "structures",
    category: "Concrete Structures",
    title: "Parallel Flange Beams & Columns",
    eyebrow: "Structural steel",
    summary: "Heavy-duty beams and columns for industrial frames, building structures and infrastructure projects.",
    description: "Rolled parallel flange sections with consistent web and flange thickness, used as primary beams, columns and crane gantry girders. Supplied cut to length with mill test certification.",
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
    applications: [ "Industrial sheds", "Crane gantries", "Multi-storey frames", "Equipment supports" ],
    image_url: "https://images.unsplash.com/photo-1441796522229-b3a3cb3d58fd?auto=format&fit=crop&w=1200&q=70",
    position: 1
  },
  {
    slug: "channels",
    key: "structures",
    category: "Concrete Structures",
    title: "Channels",
    eyebrow: "Structural steel",
    summary: "Reliable rolled channels for frames, supports, fabrication and industrial applications.",
    description: "Hot rolled MS channels with parallel or tapered flanges, used for purlins, bracing, machine bases and general fabrication work.",
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
    applications: [ "Purlins", "Bracing", "Machine bases", "Trailer chassis" ],
    image_url: "https://images.unsplash.com/photo-1593012672078-abaa5ef8acc0?auto=format&fit=crop&w=1200&q=70",
    position: 2
  },
  {
    slug: "angles",
    key: "structures",
    category: "Concrete Structures",
    title: "Angles",
    eyebrow: "Structural steel",
    summary: "Equal and unequal angle sections for bracing, frames, supports and general fabrication.",
    description: "Rolled equal and unequal angles with clean edges and consistent thickness, suited to bracing, transmission structures, shelving and general engineering.",
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
    applications: [ "Transmission towers", "Bracing", "Shelving", "Gates & grills" ],
    image_url: "https://images.unsplash.com/photo-1600965581129-eef8a214ec9d?auto=format&fit=crop&w=1200&q=70",
    position: 3
  },
  {
    slug: "ms-flat",
    key: "structures",
    category: "Concrete Structures",
    title: "M.S. Flat",
    eyebrow: "Flat steel",
    summary: "Mild steel flats for fabrication, base plates, frames and engineering work.",
    description: "Rolled mild steel flats in a wide width range, supplied in standard lengths or cut to your cutting list for base plates, brackets and frames.",
    visual: "flat",
    accent: "steel",
    tags: [ "MS flat", "Cut-to-length", "Fabrication" ],
    # Rows of the gauge difference sheet (width × thicknesses).
    sizes: [
      "65 × 6/8/10/12/16/20/25",
      "75 × 6/8/10/12/16/20/25",
      "100 × 5",
      "100 × 6/8/10/12/16/20/25",
      "125 × 5",
      "125 × 6/8/10/12/16/20/25",
      "150 × 5",
      "150 × 6/8/10/12/16/20/25",
      "160 × 6/8/10/12/16/20/25",
      "175 × 6/8/10/12/16/20/25",
      "180 × 6/8/10/12/16/20/25",
      "200 × 6/8/10/12/16/20/25",
      "220 × 6/8/10/12/16/20/25",
      "225 × 6/8/10/12/16/20/25",
      "250 × 6/8/10/12/16/20/25",
      "275 × 6/8/10/12/16/20/25"
    ],
    has_guage_price: true,
    specs: [
      [ "Grade", "IS 2062 E250" ],
      [ "Thickness", "3 mm – 25 mm" ],
      [ "Length", "6 m standard, cut to order" ],
      [ "Finish", "Mill finish" ]
    ],
    applications: [ "Base plates", "Brackets", "Frames", "General fabrication" ],
    image_url: "https://images.unsplash.com/photo-1600965593858-cb2ba22ca853?auto=format&fit=crop&w=1200&q=70",
    position: 4
  },
  {
    slug: "ms-square-round",
    key: "structures",
    category: "Concrete Structures",
    title: "M.S. Square & Round",
    eyebrow: "Bar sections",
    summary: "Round and square mild steel sections suitable for machining, fabrication and general engineering.",
    description: "Bright and mill finish round and square bars for machining, shafts, pins, grills and general engineering applications.",
    visual: "round",
    accent: "ember",
    tags: [ "Round", "Square", "Engineering" ],
    sizes: [ "10 mm", "12 mm", "16/18/20/22/25 mm", "28/30/32/34/36/38 mm" ],
    has_guage_price: true,
    specs: [
      [ "Grade", "IS 2062 / EN8 on request" ],
      [ "Length", "3 m – 6 m" ],
      [ "Finish", "Mill or bright" ],
      [ "Tolerance", "As per IS 1732" ]
    ],
    applications: [ "Machined parts", "Shafts & pins", "Grills", "Fencing" ],
    image_url: "https://images.unsplash.com/photo-1609627016501-b862497c7294?auto=format&fit=crop&w=1200&q=70",
    position: 5
  },
  {
    slug: "tmt-rebars",
    key: "tmt",
    category: "TMT & Reinforcement",
    title: "TMT Rebars",
    eyebrow: "Reinforcement steel",
    summary: "Deformed reinforcement bars designed for strength, bond and dependable performance in concrete structures.",
    description: "Thermo-mechanically treated reinforcement bars with a ribbed surface for superior bond strength, supplied in standard 12 m lengths and cut-to-length bundles.",
    visual: "rebar",
    accent: "ember",
    tags: [ "Fe 500D", "Rebar", "Infrastructure" ],
    sizes: [ "8 mm", "10 mm", "12 mm", "16 mm", "20 mm", "25 mm", "32 mm" ],
    has_guage_price: true,
    specs: [
      [ "Grade", "Fe 500 / Fe 500D / Fe 550D" ],
      [ "Length", "12 m standard" ],
      [ "Standard", "IS 1786" ],
      [ "Certification", "Mill test certificate with every lot" ]
    ],
    applications: [ "RCC frames", "Bridges & flyovers", "Foundations", "Industrial flooring" ],
    image_url: "https://images.unsplash.com/photo-1618332295161-700f3d82ed18?auto=format&fit=crop&w=1200&q=70",
    position: 6
  },
  {
    slug: "tubes-and-pipes",
    key: "pipes",
    category: "Tubes & Pipes",
    title: "Tubes & Pipes",
    eyebrow: "ERW sections",
    summary: "Round, square and rectangular tube sections for construction, fencing, machinery and fabrication.",
    description: "ERW welded round, square and rectangular hollow sections with uniform wall thickness, used across structural, mechanical and architectural work.",
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
    applications: [ "Structural frames", "Fencing & gates", "Furniture", "Machinery guards" ],
    image_url: "https://images.unsplash.com/photo-1622109912940-2bddde35274d?auto=format&fit=crop&w=1200&q=70",
    position: 7
  },
  {
    slug: "sheets-and-plates",
    key: "sheets",
    category: "Steel Sheets & Plates",
    title: "Sheets & Plates",
    eyebrow: "Flat steel",
    summary: "Steel sheets and plates for structural fabrication, industrial components and project requirements.",
    description: "Hot rolled sheets and plates in a range of thicknesses, supplied sheared or flame cut to your drawing for base plates, gussets and tank work.",
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
    applications: [ "Base plates", "Gussets", "Tanks & hoppers", "Structural fabrication" ],
    image_url: "https://images.unsplash.com/photo-1627922529156-41f27fb6f7ac?auto=format&fit=crop&w=1200&q=70",
    position: 8
  },
  {
    slug: "ms-pipes",
    key: "ms-pipes",
    category: "MS Pipes",
    title: "MS Pipes",
    eyebrow: "Mild steel",
    summary: "Mild steel pipes for structural, utility, scaffolding, fencing and general engineering applications.",
    description: "Mild steel pipes in nominal bore and outside diameter sizes for water lines, structural columns, scaffolding and general utility work.",
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
    applications: [ "Water & utility lines", "Scaffolding", "Structural columns", "Fencing" ],
    image_url: "https://images.unsplash.com/photo-1651611790023-53bd5b6fb59b?auto=format&fit=crop&w=1200&q=70",
    position: 9
  }
].freeze

PRODUCTS.each do |attributes|
  product = Product.find_or_initialize_by(slug: attributes[:slug])
  product.assign_attributes(attributes)
  product.save!
end

puts "Seeded #{Product.count} product families."

# A development sign-in so the admin subdomain can be reached without a console
# round-trip. Production admins are created deliberately, never seeded.
if Rails.env.development?
  admin = Admin.find_or_initialize_by(email: "admin@swastik.example")
  if admin.new_record?
    admin.password = "password123"
    admin.save!
    puts "Created development admin admin@swastik.example / password123"
  end
  # The development admin predates roles; make sure it can reach every page.
  admin.update!(role: :super_user, status: :active) unless admin.super_user? && admin.active?
end

# Demo data for development: one staff and one owner sign-in, the gauge
# difference sheet (W.E.F. 6 April 2026), billing settings and a fortnight of
# basic prices, so the home page "Get your quote" works end to end. Basic
# prices and enquiries are dummy figures.
if Rails.env.development?
  demo_admins = {
    staff: "staff@swastik.example",
    owner: "owner@swastik.example"
  }.to_h do |role, email|
    demo = Admin.find_or_initialize_by(email: email)
    demo.password = "password123" if demo.new_record?
    demo.update!(role: role, status: :active)
    [ role, demo ]
  end
  staff, owner = demo_admins.values_at(:staff, :owner)
  puts "Demo admins: staff@swastik.example / owner@swastik.example (password123)"

  Setting.current.update!(gst_percent: 18, loading_charges: 2000, updated_by: owner)

  guage_session = GuageSession.find_by(starts_on: Date.new(2026, 4, 6)) ||
                  GuageSession.create!(starts_on: Date.new(2026, 4, 6), ends_on: Date.new(2027, 4, 5), created_by: owner)

  heavy = "6/8/10/12/16/20/25"
  guage_sheet = {
    "ms-flat" => {
      "65 × #{heavy}" => 6300, "75 × #{heavy}" => 6300, "100 × 5" => 8100, "100 × #{heavy}" => 6800,
      "125 × 5" => 8800, "125 × #{heavy}" => 6800, "150 × 5" => 8800, "150 × #{heavy}" => 6800,
      "160 × #{heavy}" => 7800, "175 × #{heavy}" => 8800, "180 × #{heavy}" => 7800, "200 × #{heavy}" => 7800,
      "220 × #{heavy}" => 8800, "225 × #{heavy}" => 8800, "250 × #{heavy}" => 9300, "275 × #{heavy}" => 10_300
    },
    "ms-square-round" => {
      "10 mm" => 7500, "12 mm" => 7500, "16/18/20/22/25 mm" => 6800, "28/30/32/34/36/38 mm" => 6300
    },
    "tmt-rebars" => {
      "8 mm" => 7000, "10 mm" => 5500, "12 mm" => 5500, "16 mm" => 5500, "20 mm" => 5500, "25 mm" => 5500, "32 mm" => 7000
    }
  }.freeze

  # Dummy basic rates (₹/MT) the daily sheet walks around over the last 14 days.
  basic_rates = { "ms-flat" => 50_500, "ms-square-round" => 49_000, "tmt-rebars" => 48_000 }.freeze

  if guage_session.in_progress?
    guage_sheet.each do |slug, prices|
      product = Product.find_by!(slug: slug)
      prices.each do |size, price|
        row = guage_session.guage_prices.find_or_initialize_by(product: product, size: size)
        row.entered_by ||= staff
        row.update!(price: price, updated_by: staff)
      end
    end
    puts "Seeded #{guage_session.guage_prices.count} gauge prices for the #{guage_session.label} session."
  else
    puts "Skipped gauge prices: the #{guage_session.label} session isn't in progress today."
  end

  basic_rates.each do |slug, base|
    product = Product.find_by!(slug: slug)
    13.downto(0).each do |days_ago|
      date = Date.current - days_ago
      price = base + (((date.yday * 37 + product.id * 11) % 9) - 4) * 250
      row = product.daily_prices.find_or_initialize_by(priced_on: date)
      row.update!(price: price, admin: staff) if row.new_record?
    end
  end
  puts "Seeded basic prices for the last 14 days."

  [
    { name: "Anil Verma", company: "Verma Infra Projects", email: "anil@vermainfra.example", phone: "+91 98270 11223",
      product_key: "tmt", quantity: "40 tonnes", delivery_location: "Bilaspur",
      message: "Fe 550D 12 mm and 16 mm for a G+4 residential block, phased over six weeks." },
    { name: "Sunita Rao", company: "Rao Fabricators", email: "sunita@raofab.example", phone: "+91 94252 33445",
      product_key: "structures", quantity: "12 tonnes", delivery_location: "Raipur",
      message: "MS flats 100 × 8 and 150 × 10 for conveyor frames. Need mill test certificates." }
  ].each { |attributes| Enquiry.find_or_create_by!(email: attributes[:email]) { |enquiry| enquiry.assign_attributes(attributes) } }
end
