require "test_helper"

class SeoControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = Product.create!(slug: "tmt-rebars", key: "tmt", category: "TMT & Reinforcement", title: "TMT Rebars",
                               summary: "High-strength reinforcement bars.", position: 1, visual: "rebar",
                               specs: [ [ "Grade", "Fe 500D" ] ], sizes: [ "8 mm", "12 mm" ])
  end

  test "robots.txt allows crawlers, AI bots included, and points at the sitemap" do
    get "/robots.txt"

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.body, "User-agent: *\n"
    assert_includes response.body, "User-agent: GPTBot\n"
    assert_includes response.body, "User-agent: ClaudeBot\n"
    assert_includes response.body, "Allow: /\n"
    assert_includes response.body, "Disallow: /enquiries\n"
    assert_match %r{^Sitemap: http://www\.example\.com/sitemap\.xml$}, response.body
  end

  test "robots.txt on the admin subdomain disallows everything" do
    host! "admin.example.com"
    get "/robots.txt"

    assert_response :success
    assert_equal "User-agent: *\nDisallow: /\n", response.body
  end

  test "sitemap lists the static pages and every product" do
    get "/sitemap.xml"

    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes response.body, "<loc>http://www.example.com/</loc>"
    assert_includes response.body, "<loc>http://www.example.com/contact</loc>"
    assert_includes response.body, "<loc>http://www.example.com/products/tmt-rebars</loc>"
  end

  test "llms.txt summarises the site and links the products" do
    get "/llms.txt"

    assert_response :success
    assert_equal "text/markdown", response.media_type
    assert_includes response.body, "# #{Catalog::COMPANY[:name]}"
    assert_includes response.body, "[TMT Rebars](http://www.example.com/products/tmt-rebars)"
    assert_includes response.body, "TMT & Reinforcement"
  end

  test "llms-full.txt includes specifications and FAQs" do
    get "/llms-full.txt"

    assert_response :success
    assert_includes response.body, "- Grade: Fe 500D"
    assert_includes response.body, Catalog::FAQS.first[:question]
  end

  test "SITE_URL pins the canonical origin" do
    ENV["SITE_URL"] = "https://www.swastik.test/"
    get "/sitemap.xml"

    assert_includes response.body, "<loc>https://www.swastik.test/products/tmt-rebars</loc>"
  ensure
    ENV.delete("SITE_URL")
  end

  test "public pages carry canonical, social and structured data tags" do
    get product_path(@product.slug, utm_source: "x")

    assert_response :success
    assert_select "link[rel=canonical][href=?]", "http://www.example.com/products/tmt-rebars"
    assert_select "meta[name=description]"
    assert_select "meta[name=robots][content^='index, follow']"
    assert_select "meta[property='og:title'][content*='TMT Rebars']"
    assert_select "meta[name='twitter:card'][content=summary_large_image]"

    graph = JSON.parse(css_select("script[type='application/ld+json']").first.text)["@graph"]
    types = graph.map { |node| node["@type"] }
    assert_includes types, "Product"
    assert_includes types, "BreadcrumbList"
    assert_includes types, [ "Organization", "LocalBusiness" ]
  end

  test "contact page publishes its FAQs as FAQPage data" do
    get contact_path

    graph = JSON.parse(css_select("script[type='application/ld+json']").first.text)["@graph"]
    faq = graph.find { |node| node["@type"] == "FAQPage" }
    assert_equal Catalog::FAQS.size, faq["mainEntity"].size
  end

  test "crawlers reporting an old Chrome build are not turned away" do
    get root_path, headers: { "User-Agent" => "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm) Chrome/100.0.4896.127 Safari/537.36" }

    assert_response :success
  end

  test "admin subdomain responses are marked noindex" do
    host! "admin.example.com"
    get new_admin_session_path

    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
  end
end
