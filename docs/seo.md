# SEO, structured data and AI crawlers

## Environment variables

Every variable is listed, with its default, in [`.env.example`](../.env.example).
Copy it to `.env` for development (loaded by dotenv). In production, set the
values in the deploy environment.

All optional. Every company value falls back to the default in
`app/models/catalog.rb`, and is read once at boot, so **restart the app after
changing one**. Each value updates everywhere it is used: navbar, footer,
contact and about pages, structured data, `llms.txt` and the manifest.

| Variable | Default | Used for |
| --- | --- | --- |
| `SITE_URL` | current request origin | Canonical URLs, sitemap, robots, Open Graph. **Set this in production**, e.g. `https://www.example.com` (no trailing slash needed). |
| `GOOGLE_SITE_VERIFICATION` | — | `google-site-verification` meta tag (Search Console "HTML tag" method) |
| `BING_SITE_VERIFICATION` | — | `msvalidate.01` meta tag (Bing Webmaster Tools) |
| `COMPANY_NAME` | Swastik Enterprise | Brand name in titles, schema, footer |
| `COMPANY_LEGAL_NAME` | Swastik Enterprise Steel & Structural Solutions | Footer, schema `legalName` |
| `COMPANY_TAGLINE` | Iron & steel, engineered for the long haul | Preloader, schema `slogan` |
| `COMPANY_SUMMARY` | A steel manufacturing and supply house… | Footer, default meta description |
| `COMPANY_ESTABLISHED` | 1988 | Copy, schema `foundingDate` |
| `COMPANY_PHONE` / `COMPANY_PHONE_ALT` | +91 98261 00000 / +91 771 222 5151 | Display and `tel:` links, schema |
| `COMPANY_EMAIL` | sales@swastikenterprise.example | Display and `mailto:` links, schema |
| `COMPANY_STREET` | Industrial Area | Address |
| `COMPANY_CITY` | Raipur | Address, page titles ("… in Raipur") |
| `COMPANY_REGION` | Chhattisgarh | Address |
| `COMPANY_REGION_CODE` | IN-CT | `geo.region` meta |
| `COMPANY_POSTAL_CODE` | 492001 | Address |
| `COMPANY_COUNTRY` / `COMPANY_COUNTRY_CODE` | India / IN | Address |
| `COMPANY_ADDRESS` | built from the parts above | Overrides the one-line display address |
| `COMPANY_LATITUDE` / `COMPANY_LONGITUDE` | — | Schema `geo`, `geo.position` meta. Strongly recommended for local search. |
| `COMPANY_MAP_URL` | Google Maps search for the address | "Open in Maps" link, schema `hasMap`. Use your Google Business Profile share link. |
| `COMPANY_HOURS` | Mon – Sat, 9:30 am – 6:30 pm IST | Displayed hours |
| `COMPANY_OPEN_DAYS` | Monday,…,Saturday | Schema opening hours (comma-separated) |
| `COMPANY_OPENS` / `COMPANY_CLOSES` | 09:30 / 18:30 | Schema opening hours (24h) |
| `COMPANY_AREA_SERVED` | Chhattisgarh,Madhya Pradesh,… | Schema `areaServed`, `llms.txt` |
| `COMPANY_LANGUAGES` | English,Hindi | Schema `availableLanguage` |
| `COMPANY_LINKEDIN_URL`, `COMPANY_INSTAGRAM_URL`, `COMPANY_FACEBOOK_URL` | network home pages | Footer links; schema `sameAs` once they point at a real profile |
| `COMPANY_YOUTUBE_URL`, `COMPANY_X_URL` | — | Footer and `sameAs`, shown only when set |

The GSTIN saved on the admin Settings page is published as the schema `taxID`.

## What is generated

- **Every public page** (`shared/_seo_meta`, `SeoHelper`): title, meta
  description (trimmed to 160 chars), canonical URL (query strings stripped),
  robots directives allowing large image previews, Open Graph and Twitter cards,
  geo meta, and one JSON-LD `@graph` with `Organization`+`LocalBusiness`,
  `WebSite`, the page's `WebPage` subtype and a `BreadcrumbList`.
- **Page-specific schema**: `Product` with specs as `additionalProperty`
  (product pages), `ItemList` (catalogue), `FAQPage` (contact), `AboutPage`,
  `ContactPage`, `CollectionPage`, `ItemPage`.
- **`/robots.txt`**: allows every crawler, AI training and answer bots
  included, and blocks the form endpoints. The admin subdomain gets
  `Disallow: /`, and every admin response also sends `X-Robots-Tag: noindex`.
- **`/sitemap.xml`**: the static pages plus every product, with `lastmod` and
  image entries.
- **`/llms.txt`, `/llms-full.txt`**: Markdown summaries for LLMs
  (llmstxt.org). The full version adds specifications, process and FAQs.
- **`/manifest.json`**, favicons, app icons, `/logo.png` (structured-data
  logo) and `/og-image.png` (1200×630 share image), all generated from the
  logo. See "Brand assets" below.

## Brand assets

Everything logo-derived comes from `script/brand/logo-source.jpg`. To replace
the logo, run `script/brand/build path/to/new-logo.jpg` (needs Pillow,
ImageMagick and librsvg). It cuts the artwork out of its white background and
writes:

- `app/assets/images/brand/`: `lockup-light/-dark.webp` (mark beside the
  wordmark, used in the navbar and footer via `brand_lockup`), `mark.webp`
  (symbol only, used in the admin chrome and preloader via `brand_mark`), and
  the stacked `logo-light/-dark.webp`. `-dark` variants have light lettering
  for dark backgrounds.
- `app/assets/images/brand/lockup-light.png`: the logo in the quotation PDF
  (`QuotePdf`), since Prawn only embeds PNG and JPEG.
- `public/`: `favicon.ico`, `favicon-32x32.png`, `icon.png`, `icon-192.png`,
  `icon-maskable.png`, `apple-touch-icon.png`, `logo.png`, `og-image.png`.

The crop boxes in `script/brand/cutout.py` match the current 1536×1024
artwork, so adjust them if the new file is laid out differently. The share
image's copy lives in `script/brand/og-image.svg`.

## Adding a page

1. Start the view with `content_for :title, page_title("…")` (about 60 characters
   including the " | Company" suffix) and `content_for :description, "…"` (140–160 characters).
2. Use `shared/_page_hero` with a `breadcrumb:`; it registers the breadcrumb
   schema itself.
3. Optionally `page_type "AboutPage"` and `structured_data(...)` for extra nodes.
4. Add the route to `SeoController::STATIC_PAGES` so it lands in the sitemap,
   and to the "Pages" list in `app/views/seo/llms.text.erb`.

## After deploying

1. Set `SITE_URL` and the real `COMPANY_*` values, then restart.
2. Verify the domain in Google Search Console and Bing Webmaster Tools (set the
   verification env vars, or use DNS), and submit `/sitemap.xml` in both.
3. Create or claim the Google Business Profile with the **same** name, address
   and phone as the site. Consistent NAP is the biggest local-ranking factor.
4. Check the pages with Google's Rich Results Test and the Schema.org validator.
