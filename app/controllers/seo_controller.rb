# Machine-readable files for search engines and AI crawlers:
#
#   /robots.txt     crawl rules (the admin subdomain disallows everything)
#   /sitemap.xml    every public URL, products with their last-modified date
#   /llms.txt       a short Markdown guide to the site for LLMs (llmstxt.org)
#   /llms-full.txt  the same plus full product specifications and FAQs
#
# They're rendered rather than served from public/ so the URLs follow SITE_URL
# and the product list stays in step with the admin catalogue.
class SeoController < ApplicationController
  # Crawlers that respect robots.txt and are explicitly welcome. Listing them
  # in the same group as "*" applies identical rules while making the intent
  # explicit for bots that look for their own name.
  CRAWLERS = [
    # Search engines
    "Googlebot", "Googlebot-Image", "Bingbot", "DuckDuckBot", "Slurp", "YandexBot", "Applebot",
    # AI search, answer and assistant bots
    "OAI-SearchBot", "ChatGPT-User", "Claude-SearchBot", "Claude-User", "PerplexityBot", "Perplexity-User",
    "DuckAssistBot", "MistralAI-User", "Bytespider",
    # AI training crawlers (allowed by choice, for visibility in model answers)
    "GPTBot", "ClaudeBot", "anthropic-ai", "Google-Extended", "Applebot-Extended", "CCBot",
    "Meta-ExternalAgent", "Amazonbot", "cohere-ai",
    # Link previews
    "facebookexternalhit", "LinkedInBot", "Twitterbot", "WhatsApp", "Slackbot"
  ].freeze

  # Paths with no content worth indexing: form endpoints and the health check.
  DISALLOWED_PATHS = %w[/enquiries /quotes /up].freeze

  STATIC_PAGES = [
    { path: :root_path, priority: "1.0", changefreq: "weekly" },
    { path: :products_path, priority: "0.9", changefreq: "weekly" },
    { path: :about_path, priority: "0.7", changefreq: "monthly" },
    { path: :plant_path, priority: "0.7", changefreq: "monthly" },
    { path: :clients_path, priority: "0.6", changefreq: "monthly" },
    { path: :contact_path, priority: "0.8", changefreq: "monthly" }
  ].freeze

  before_action { expires_in 1.hour, public: true }

  def robots
    body = admin_host? ? "User-agent: *\nDisallow: /\n" : public_robots
    render plain: body, content_type: "text/plain"
  end

  def sitemap
    @pages = STATIC_PAGES.map { |page| page.merge(url: absolute_url(send(page[:path]))) }
    @products = Product.ordered
    render formats: :xml
  end

  def llms
    load_llms_content
    render "seo/llms", formats: :text, content_type: "text/markdown"
  end

  def llms_full
    load_llms_content
    @full = true
    render "seo/llms", formats: :text, content_type: "text/markdown"
  end

  private

  def admin_host?
    request.subdomain == "admin"
  end

  def public_robots
    lines = [ "# #{Catalog::COMPANY[:name]} — #{absolute_url("/")}", "" ]
    lines += ([ "*" ] + CRAWLERS).map { |agent| "User-agent: #{agent}" }
    lines << "Allow: /"
    lines += DISALLOWED_PATHS.map { |path| "Disallow: #{path}" }
    lines += [
      "",
      "# Content signals (contentsignals.org): search indexing, AI answers and AI training are all permitted.",
      "Content-Signal: search=yes, ai-input=yes, ai-train=yes",
      "",
      "Sitemap: #{absolute_url("/sitemap.xml")}",
      "",
      "# Plain-language summary for LLMs: #{absolute_url("/llms.txt")}",
      "# Full catalogue for LLMs: #{absolute_url("/llms-full.txt")}"
    ]
    lines.join("\n") + "\n"
  end

  def load_llms_content
    @company = Catalog::COMPANY
    @products = Product.ordered
    @faqs = Catalog::FAQS
  end

  def absolute_url(path) = helpers.absolute_url(path)
end
