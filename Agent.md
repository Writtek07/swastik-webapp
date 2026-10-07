# Working notes for agents

Rails 8 + Tailwind CSS v4 + Stimulus. No database-backed content models for the
marketing pages — everything renders from `Catalog`.

## Where things live

- **Content**: [app/models/catalog.rb](app/models/catalog.rb). Products, nav,
  stats, values, process, clients, FAQs. Add a product here and it appears in the
  navbar mega menu, the catalogue, the footer and the enquiry form's product
  select automatically.
- **Design tokens and component classes**:
  [app/assets/stylesheets/site.css](app/assets/stylesheets/site.css), imported
  from `application.tailwind.css`. Tailwind v4 processes the `@apply` rules, so
  the file must stay in the Tailwind entrypoint's import graph.
- **Product artwork**: `app/views/shared/visuals/_<visual>.html.erb`, selected by
  the `visual` key on a product. Add a new partial and reference it by name.
- **Icons**: `IconsHelper::ICONS` in
  [app/helpers/icons_helper.rb](app/helpers/icons_helper.rb). Call
  `icon(:name, class: "...")`. Unknown names render nothing rather than raising.

## Conventions

- Views use `shared/_page_hero`, `shared/_section_heading`, `shared/_product_card`,
  `shared/_stats`, `shared/_cta` and `shared/_enquiry_form`. Prefer these over
  new markup so spacing and typography stay consistent.
- Every page wraps its content in `<div data-controller="reveal">` and marks
  animatable blocks with `data-reveal-target="item"`. Counters use
  `data-counter` plus `data-suffix`.
- Stimulus controllers must be registered in
  `app/javascript/controllers/index.js`.
- A controller's targets must live inside the element carrying
  `data-controller`. The navbar controller wraps the header, scrim and drawer in
  a `display: contents` div for this reason; the video modal controller sits on
  `<body>` so triggers anywhere on the page can reach it.
- The mega-menu panel is a **sibling** of its trigger group, not a child — it has
  to be, because it spans the full header width. So the hover-close is bound to
  the whole `<header>` (`mouseleave->site-nav#scheduleClose`) rather than to the
  group, and each panel carries `mouseenter->site-nav#keepOpen`. Binding
  `mouseleave` to the group instead makes the panel close the moment the pointer
  travels from the trigger down into it, which breaks clicking any link inside.

## Tailwind v4 gotchas

- `@apply` only accepts real utilities. It cannot reference another custom class
  (`.btn`), the `group` marker, or a hand-written class like `.hatch`. Share
  styles by listing selectors together instead.
- `dark:` is bound to the `.dark` class via `@custom-variant`, not to
  `prefers-color-scheme`.

## Checks

```bash
yarn build && yarn build:css   # assets
bin/rails test                 # tests
bin/rubocop                    # style
bin/brakeman --no-pager        # security
```
