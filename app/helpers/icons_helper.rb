# Inline SVG icon set.
#
# Icons are stored as raw path markup so views can call `icon(:phone)` and get a
# crisp, themeable SVG without an external icon font or network request.
module IconsHelper
  ICONS = {
    "arrow-right" => '<path d="M5 12h14M13 6l6 6-6 6"/>',
    "arrow-up-right" => '<path d="M7 17 17 7M8 7h9v9"/>',
    "arrow-down" => '<path d="M12 5v14M6 13l6 6 6-6"/>',
    "arrow-left" => '<path d="M19 12H5M11 18l-6-6 6-6"/>',
    "menu" => '<path d="M4 7h16M4 12h16M4 17h16"/>',
    "close" => '<path d="M6 6l12 12M18 6 6 18"/>',
    "plus" => '<path d="M12 5v14M5 12h14"/>',
    "minus" => '<path d="M5 12h14"/>',
    "chevron-down" => '<path d="m6 9 6 6 6-6"/>',
    "chevron-right" => '<path d="m9 6 6 6-6 6"/>',
    "sun" => '<circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/>',
    "moon" => '<path d="M20.7 15.4A8.5 8.5 0 1 1 8.6 3.3a6.7 6.7 0 0 0 12.1 12.1Z"/>',
    "phone" => '<path d="M6.5 3h3l1.5 4-2 1.5a12 12 0 0 0 6.5 6.5L17 13l4 1.5v3a2 2 0 0 1-2.2 2A17 17 0 0 1 3 5.2 2 2 0 0 1 5 3Z"/>',
    "mail" => '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3.5 7 8.5 6 8.5-6"/>',
    "pin" => '<path d="M12 21s7-5.6 7-11a7 7 0 1 0-14 0c0 5.4 7 11 7 11Z"/><circle cx="12" cy="10" r="2.6"/>',
    "clock" => '<circle cx="12" cy="12" r="9"/><path d="M12 7v5.5l3.5 2"/>',
    "play" => '<path d="M8 5.5v13l11-6.5-11-6.5Z"/>',
    "check" => '<path d="m4.5 12.5 5 5 10-11"/>',
    "check-circle" => '<circle cx="12" cy="12" r="9"/><path d="m8 12.5 2.8 2.8L16 9.5"/>',
    "download" => '<path d="M12 4v11M7 11l5 5 5-5M5 20h14"/>',
    "external" => '<path d="M14 4h6v6M20 4l-9 9M18 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h5"/>',
    "shield" => '<path d="M12 3l7 3v6c0 4.4-3 8-7 9-4-1-7-4.6-7-9V6l7-3Z"/><path d="m9 12 2 2 4-4"/>',
    "handshake" => '<path d="M3 12l4-4 3 3 2-2 2 2 3-3 4 4-5 5-2-2-2 2-2-2-2 2-5-5Z"/>',
    "spark" => '<path d="M12 3v5M12 16v5M4.5 12h5M14.5 12h5M6.7 6.7l3 3M14.3 14.3l3 3M17.3 6.7l-3 3M9.7 14.3l-3 3"/>',
    "helmet" => '<path d="M4 15a8 8 0 0 1 16 0"/><path d="M3 15h18v3H3z"/><path d="M10 7.5V4h4v3.5"/>',
    "leaf" => '<path d="M20 4c-9 0-14 4-14 10a6 6 0 0 0 6 6c6 0 8-6 8-16Z"/><path d="M6 20c2-6 6-9 11-11"/>',
    "ruler" => '<path d="M3 15 15 3l6 6L9 21l-6-6Z"/><path d="m7 11 2 2M10 8l2 2M13 5l2 2"/>',
    "saw" => '<path d="M3 8h13l5 4-5 4H3z"/><path d="M6 8v8M10 8v8M14 8v8"/>',
    "certificate" => '<rect x="4" y="3" width="16" height="13" rx="1.5"/><path d="M8 7h8M8 11h5"/><path d="m9 16-1 5 4-2 4 2-1-5"/>',
    "calendar" => '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
    "truck" => '<path d="M3 7h11v9H3z"/><path d="M14 10h4l3 3v3h-7z"/><circle cx="7" cy="18" r="1.8"/><circle cx="17" cy="18" r="1.8"/>',
    "repeat" => '<path d="M4 9V7a2 2 0 0 1 2-2h11l-3-3"/><path d="M20 15v2a2 2 0 0 1-2 2H7l3 3"/>',
    "intake" => '<path d="M4 6h16l-2 5H6L4 6Z"/><path d="M6 11v8h12v-8"/><path d="M10 15h4"/>',
    "furnace" => '<path d="M5 20V9l7-5 7 5v11z"/><path d="M9 20v-6h6v6"/><path d="M12 4V2"/>',
    "casting" => '<path d="M4 5h16v6H4z"/><path d="M8 11v4M16 11v4"/><path d="M6 15h12v5H6z"/>',
    "rolling" => '<circle cx="7" cy="12" r="3"/><circle cx="17" cy="12" r="3"/><path d="M10 12h4M3 6h18M3 18h18"/>',
    "lab" => '<path d="M9 3h6M10 3v6l-5 9a2 2 0 0 0 1.8 3h10.4A2 2 0 0 0 19 18l-5-9V3"/><path d="M7.5 15h9"/>',
    "layers" => '<path d="m12 3 9 5-9 5-9-5 9-5Z"/><path d="m3 13 9 5 9-5"/>',
    "grid" => '<rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>',
    "factory" => '<path d="M3 20V10l5 3V10l5 3V10l5 3v7z"/><path d="M3 20h18"/><path d="M7 20v-3M12 20v-3M17 20v-3"/>',
    "users" => '<circle cx="9" cy="8" r="3.2"/><path d="M3 20a6 6 0 0 1 12 0"/><path d="M16 5.5a3 3 0 0 1 0 5.6M17 20a6 6 0 0 0-2-4.5"/>',
    "award" => '<circle cx="12" cy="9" r="5.5"/><path d="m8.5 13.5-1.5 7 5-2.5 5 2.5-1.5-7"/>',
    "linkedin" => '<rect x="3" y="3" width="18" height="18" rx="2"/><path d="M7 10v7M7 7v.01M11 17v-4a2 2 0 0 1 4 0v4"/>',
    "instagram" => '<rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4"/><path d="M17 7v.01"/>',
    "facebook" => '<path d="M14 8h3V4h-3a4 4 0 0 0-4 4v3H7v4h3v6h4v-6h3l1-4h-4V8Z"/>',
    "whatsapp" => '<path d="M20 12a8 8 0 0 1-11.8 7L4 20l1.1-4A8 8 0 1 1 20 12Z"/><path d="M9 9.5c0 3 2.5 5.5 5.5 5.5"/>',
    "quote" => '<path d="M9 6c-3 1.5-4.5 4-4.5 7.5A4.5 4.5 0 0 0 9 18a3.5 3.5 0 0 0 0-7c-.5 0-1 .1-1.4.3C8 9.6 9 8.4 10.5 7.5Z"/><path d="M19 6c-3 1.5-4.5 4-4.5 7.5A4.5 4.5 0 0 0 19 18a3.5 3.5 0 0 0 0-7c-.5 0-1 .1-1.4.3C18 9.6 19 8.4 20.5 7.5Z"/>',
    "target" => '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="4.5"/><circle cx="12" cy="12" r="1"/>',
    "globe" => '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.6 3.8 5.6 3.8 9S14.5 18.4 12 21c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3Z"/>',
    "search" => '<circle cx="11" cy="11" r="6.5"/><path d="m20 20-4.4-4.4"/>',
    "sliders" => '<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>',
    "bolt" => '<path d="M13 3 5 14h6l-1 7 8-11h-6l1-7Z"/>'
  }.freeze

  # Renders an inline SVG. `name` is a key of ICONS; unknown names render nothing
  # so a typo degrades to a missing glyph instead of raising in production.
  #
  # `class` is passed through **options rather than as a named parameter because
  # `class` is a Ruby keyword and cannot be used as a bare argument value.
  def icon(name, stroke: 1.6, **options)
    path = ICONS[name.to_s]
    return "".html_safe if path.nil?

    tag.svg(
      path.html_safe,
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      "stroke-width": stroke,
      "stroke-linecap": "round",
      "stroke-linejoin": "round",
      "aria-hidden": "true",
      # The default 20px size is set as SVG attributes rather than `h-5 w-5`
      # classes: attributes lose to any CSS, so contextual rules such as
      # `.btn-primary svg` can still size an icon that was given no class.
      **(options.key?(:class) ? {} : { width: 20, height: 20 }),
      **options
    )
  end
end
