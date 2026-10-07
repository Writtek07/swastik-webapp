# Swastik Enterprise — steel & structural website

A multi-page marketing site for a steel manufacturer and supplier, built with
Rails 8, Tailwind CSS v4 and Stimulus. The information architecture follows a
conventional industrial-group site (home, about, products, plant, clients,
contact) with a video-led hero and scroll-driven interactions.

## Pages

| Route | Purpose |
| --- | --- |
| `/` | Video hero, product families, capability, applications, stats, values, FAQ |
| `/about` | Company story, milestones timeline, values |
| `/products` | Filterable catalogue of all nine product families |
| `/products/:slug` | Family detail: overview, specification table, sizes, related families |
| `/plant` | Six-stage process, facility capability, quality assurance |
| `/clients` | Clientele grid, approvals and registrations, sectors |
| `/contact` | Contact details, enquiry form, FAQ |

## Architecture

```
app/
  controllers/
    pages_controller.rb        # home, about, plant, clients, contact
    products_controller.rb     # catalogue index + family detail
    enquiries_controller.rb    # enquiry form POST
  models/
    catalog.rb                 # all marketing content (products, nav, copy)
    enquiry.rb                 # persisted enquiry with validations
  helpers/
    icons_helper.rb            # inline SVG icon set
    site_helper.rb             # nav state, page metadata, formatting
  javascript/controllers/
    site_nav_controller.js     # mega menu, mobile drawer, theme toggle
    reveal_controller.js       # scroll reveal + animated counters
    hero_video_controller.js   # hero background video with CSS fallback
    catalog_controller.js      # product filtering with URL sync
    accordion_controller.js    # FAQ and mobile nav groups
    slider_controller.js       # scroll-snap slider
    video_modal_controller.js  # company film lightbox
    enquiry_controller.js      # form validation + submit state
    dismiss_controller.js      # flash message dismissal
  views/
    layouts/application.html.erb
    shared/                    # navbar, footer, hero, cards, forms, visuals
    shared/visuals/            # SVG "blueprint" drawings per product family
    pages/                     # one template per static page
    products/                  # index + show
```

### Content lives in `Catalog`

Every product, navigation entry, statistic and block of marketing copy is a
plain Ruby hash in [app/models/catalog.rb](app/models/catalog.rb). Views stay
declarative, and the data can later be moved into ActiveRecord tables or a CMS
without touching a template. `Catalog::NAV` drives the navbar, mega menu, mobile
drawer and footer from a single source.

### Design system

Tokens and component classes live in
[app/assets/stylesheets/site.css](app/assets/stylesheets/site.css), imported by
`application.tailwind.css`. The palette is a warm graphite (`ink`) plus an ember
accent, with a sand-tinted light surface. Dark mode is class-based and persisted
to `localStorage`.

Product imagery is drawn as inline SVG "blueprint plates" in
`app/views/shared/visuals/`, so the site has no external image dependency.

## Media

The hero and the company-film lightbox are video-ready but ship with a CSS
fallback so the layout looks finished before any media exists.

To add real video:

1. Put the file in `app/assets/videos/` (create the directory).
2. Hero: set `data-hero-video-src-value` on the hero section in
   [app/views/pages/home.html.erb](app/views/pages/home.html.erb) and point the
   `<source>` at the asset path.
3. Lightbox: add `data-video-modal-url-value` (YouTube/Vimeo embed) or
   `data-video-modal-src-value` (local file) to the trigger button.

## Enquiries

`Enquiry` persists submissions with validations on name, email, message and
status. The form posts to `EnquiriesController#create` and redirects back to
`/contact#enquiry` with a flash message. Wire up mailers or a CRM sync in that
controller when ready.

## Development

```bash
bin/setup                 # install dependencies and prepare the database
bin/rails db:prepare
bin/dev                   # Rails + esbuild watch + Tailwind watch
```

Individual asset builds:

```bash
yarn build                # JavaScript bundle
yarn build:css            # Tailwind bundle
```

## Tests and checks

```bash
bin/rails test            # model, controller and integration tests
bin/rubocop               # Ruby style
bin/brakeman --no-pager   # security scan
```

## Content to replace before launch

- Company name, address, phone numbers, email and social links in
  `Catalog::COMPANY`.
- Client names in `Catalog::CLIENTS` — the current entries are indicative
  placeholders pending approval for publication.
- Approvals in `Catalog::APPROVALS` and the statistics in `Catalog::STATS`.
- Product specifications in `Catalog::PRODUCTS` should be validated against mill
  and test certificates before publication.
