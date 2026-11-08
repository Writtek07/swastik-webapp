# Formatting helpers for the admin console.
module AdminHelper
  include Pagy::Frontend

  # Rupee amount with Indian digit grouping: 1234567.5 -> "₹12,34,567.50".
  def inr(amount)
    return "—" if amount.nil?

    rupees, paise = format("%.2f", amount.abs).split(".")
    grouped = rupees.length > 3 ? "#{rupees[0...-3].reverse.scan(/\d{1,2}/).join(',').reverse},#{rupees[-3..]}" : rupees
    "#{'-' if amount.negative?}₹#{grouped}.#{paise}"
  end

  # Up / down / flat pill for a price movement. `change` may be nil (no prior day).
  def price_change_badge(change, previous: nil)
    return tag.span("New", class: "admin-delta admin-delta--new") if change.nil?
    return tag.span("No change", class: "admin-delta admin-delta--flat") if change.zero?

    up = change.positive?
    percent = previous.to_d.nonzero? ? " (#{number_with_precision((change / previous * 100).abs, precision: 1)}%)" : ""
    tag.span(class: "admin-delta #{up ? 'admin-delta--up' : 'admin-delta--down'}") do
      safe_join([ up ? "▲" : "▼", " #{inr(change.abs)}#{percent}" ])
    end
  end

  # True when the signed-in admin may reach `action` on an admin controller,
  # e.g. admin_can?(:products, :edit). Reads the controller's require_role
  # rules, so a hidden link and a refused request always agree.
  def admin_can?(controller, action = :index)
    "Admin::#{controller.to_s.camelize}Controller".constantize.allows?(current_admin, action)
  end

  def admin_nav_link(label, path, icon_name, active:)
    link_to path, class: "admin-nav-link", aria: { current: (active ? "page" : nil) } do
      safe_join([ icon(icon_name, class: "h-4 w-4"), tag.span(label) ])
    end
  end

  ROLE_PILL_CLASSES = {
    "super_user" => "bg-ink-950 text-white",
    "owner" => "bg-ember-500/12 text-ember-700",
    "staff" => "bg-ink-900/[0.06] text-ink-600"
  }.freeze

  def admin_role_pill(admin)
    tag.span(admin.role.humanize, class: "admin-pill #{ROLE_PILL_CLASSES.fetch(admin.role)}")
  end

  def admin_status_pill(admin)
    if admin.active?
      tag.span(safe_join([ tag.span(class: "h-1.5 w-1.5 rounded-full bg-emerald-500"), "Active" ]),
               class: "admin-pill bg-emerald-500/10 text-emerald-700")
    else
      tag.span(safe_join([ tag.span(class: "h-1.5 w-1.5 rounded-full bg-ink-400"), "Inactive" ]),
               class: "admin-pill bg-ink-900/[0.05] text-ink-500")
    end
  end

  # On/off switch that flips an admin's status. `filter` is the roster's current
  # status filter, passed through so the response knows whether the row should
  # stay in the table. Deactivating asks for confirmation; reactivating doesn't.
  def admin_status_switch(admin, filter: nil)
    form_data = admin.active? ? { turbo_confirm: "Deactivate #{admin.display_name}? They'll be signed out and won't be able to sign in." } : {}

    button_to admin_staff_status_path(admin), method: :patch, params: filter ? { status: filter } : {},
              form: { class: "inline-flex", data: form_data },
              class: "admin-switch", role: "switch",
              aria: { checked: admin.active?, label: "#{admin.display_name} active" } do
      safe_join([ tag.span(tag.span(class: "admin-switch__thumb"), class: "admin-switch__track"),
                  tag.span(admin.active? ? "Active" : "Inactive", class: "admin-switch__label") ])
    end
  end

  GUAGE_SESSION_PILLS = {
    in_progress: [ "In progress", "bg-emerald-500/10 text-emerald-700" ],
    upcoming: [ "Upcoming", "bg-sky-500/10 text-sky-700" ],
    ended: [ "Ended", "bg-ink-900/[0.05] text-ink-500" ]
  }.freeze

  def guage_session_pill(guage_session)
    label, classes = GUAGE_SESSION_PILLS.fetch(guage_session.status)
    tag.span(label, class: "admin-pill #{classes}")
  end

  ENQUIRY_STATUS_PILLS = {
    "new" => "bg-ember-500/12 text-ember-700",
    "contacted" => "bg-sky-500/10 text-sky-700",
    "quoted" => "bg-amber-500/12 text-amber-700",
    "won" => "bg-emerald-500/10 text-emerald-700",
    "closed" => "bg-ink-900/[0.05] text-ink-500"
  }.freeze

  def enquiry_status_pill(enquiry)
    tag.span(enquiry.status.humanize, class: "admin-pill #{ENQUIRY_STATUS_PILLS.fetch(enquiry.status, ENQUIRY_STATUS_PILLS['closed'])}")
  end

  def admin_avatar(admin, size: "h-8 w-8 text-[10px]")
    tag.span(admin.initials, class: "admin-avatar #{size}", title: admin.email)
  end
end
