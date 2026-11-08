# Google Analytics

The public layout loads Google Tag Manager container `GTM-TWRKT9LB`, which
carries GA4 property `G-7QPZLFHJC8` with enhanced measurement on. The admin
layouts don't load it, so the back office is never tracked.

Custom events are sent with `gtag('event', …)` from
`app/javascript/lib/analytics.js`. The container honours these directly (a
plain `dataLayer.push({ event })` does **not** reach GA4, because the
container has no tags listening for it).

## What is tracked

| Event | When | Parameters |
| --- | --- | --- |
| `page_view` | Every page, including Turbo navigations and back/forward | Sent by GA4 itself (see below) |
| `generate_lead` | An enquiry **saved** by the server | `form_name`, `product_category` |
| `enquiry_error` | The server rejected an enquiry | `form_name`, `error_fields` |
| `quote_download` | A valid "Get your quote" submission (PDF download) | `product`, `size`, `quantity_mt`, `items` |
| `quote_error` | The server couldn't price a quote, or rate limit | `reason` |
| `contact_click` | `tel:`, `mailto:` or map link | `method` (phone / email / map), `section` |
| `cta_click` | Any button-styled link (`.btn-*`, `.link-arrow`) | `link_text`, `link_url`, `section` |
| `view_item` | Product page | `items` |
| `view_item_list` | Catalogue | `item_list_name`, `item_list_id` (active filter), `items` |
| `select_item` | Click on any product link (cards, menu, tiles) | `item_list_name` (section), `items` |
| `filter_products` | Catalogue category chip | `filter` |
| `faq_open` | An FAQ answer expanded | `question`, `section` |
| `video_open` | Plant film opened | `video_title`, `section` |
| `theme_change` | Light/dark toggle | `theme` |
| `scroll_depth` | 25 / 50 / 75 % of a page | `percent_scrolled` |

GA4 enhanced measurement adds `scroll` (90%), `click` (outbound links),
`file_download`, `form_start` / `form_submit`, `view_search_results` and
`video_*` on its own, so the code doesn't duplicate them.

`section` is the page section a click came from, named like the scroll
readout: e.g. "Overview", "Reach us", "Product families", "Header", "Footer".

**Never send personal data** (names, emails, phone numbers, message text).
It's against Google Analytics policy, and the tests check the lead events
for it.

## Page views and Turbo

Page views after the first load come from enhanced measurement's **"Page
changes based on browser history events"**, which is on. Turbo navigates with
`history.pushState`, and GA4 records each visit with the right URL and title.
The code deliberately doesn't send its own `page_view`: doing both doubled
every page view.

If that setting is ever switched off, Turbo navigations stop being counted.
Turn it back on, or send `page_view` on `turbo:load` instead.

The catalogue filter updates the URL, so `/products?category=tmt` is also
counted as a page view of its own.

## Adding tracking

- **A link or button:** add `data-analytics-event="event_name"` and,
  optionally, `data-analytics-params='{"key":"value"}'`. Button-styled links,
  product links and contact links are tracked automatically.
- **An outcome only the server knows** (something saved or rejected): call
  `track_event "name", key: value` in the controller before redirecting
  (`AnalyticsEvents`). The browser sends it on the next page, once.
- **Something about the page being rendered:** call
  `analytics_event "name", ...` in the view, as with `view_item`.

## GA4 settings to change (Admin)

1. **Mark key events** (Admin → Events, or Key events): `generate_lead`,
   `quote_download` and `contact_click` are the conversions.
2. **Register custom dimensions** (Admin → Custom definitions → Create
   custom dimension, scope *Event*). Parameters only appear in standard
   reports once registered: `section`, `method`, `link_text`, `form_name`,
   `product_category`, `error_fields`, `reason`, `product`, `size`, `filter`,
   `question`, `theme`, `percent_scrolled`. Add `quantity_mt` as a custom
   *metric*. The `items` arrays populate the built-in e-commerce item
   reports without any setup.
3. **Filter internal traffic** (Admin → Data streams → Configure tag settings
   → Define internal traffic) for the office IP, so staff browsing doesn't
   count as leads.
4. Use **DebugView** (Admin → DebugView) with the Tag Assistant extension to
   watch events arrive live while testing.
