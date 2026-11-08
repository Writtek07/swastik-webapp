Rails.application.routes.draw do
  # The back office lives on its own subdomain (admin.lvh.me in development) so
  # the public marketing site and the admin console never share a session.
  # Admin pages sit at the root of that subdomain (admin.lvh.me/, not
  # admin.lvh.me/admin); `module`/`as` still route to Admin::* controllers and
  # keep the admin_* helper names.
  constraints subdomain: "admin" do
    devise_for :admins, path: "auth", skip: [ :registrations ]

    scope module: :admin, as: :admin do
      root "dashboard#show"

      # Every role can browse products; only super users reach edit/update
      # (enforced in Admin::ProductsController).
      resources :products, only: [ :index, :show, :edit, :update ]

      # Enquiries from the public contact form; read-only, open to every role.
      resources :enquiries, only: [ :index, :show ]

      # One settings page (a singleton record); owners and super users can save it.
      resource :settings, only: [ :show, :update ]

      # The admin roster, for owners and super users (see Admin::StaffController).
      get "staff", to: "staff#index", as: :staff
      patch "staff/:id/status", to: "staff#update_status", as: :staff_status

      # One sheet per day: the index is the entry form plus the price history, and
      # create upserts the rows for the date being priced.
      resources :daily_prices, only: [ :index, :create ]

      # Yearly gauge prices: the index is the sheet for a session (the one in
      # progress by default) and create upserts it. Sessions themselves are
      # opened and adjusted by owners and super users.
      resources :guage_prices, only: [ :index, :create ]
      resources :guage_sessions, only: [ :new, :create, :edit, :update ]
    end
  end

  # The marketing site answers on every host except the admin subdomain, so
  # admin.lvh.me/about is a 404 rather than the public page.
  constraints ->(request) { request.subdomain != "admin" } do
    root "pages#home"

    get "about",   to: "pages#about",   as: :about
    get "plant",   to: "pages#plant",   as: :plant
    get "clients", to: "pages#clients", as: :clients
    get "contact", to: "pages#contact", as: :contact

    resources :products, only: [ :index, :show ], param: :slug
    resources :enquiries, only: [ :create ]
    # "Get your quote" on the home page; responds with a PDF download.
    resources :quotes, only: [ :create ]

    # Crawler files; see SeoController.
    get "sitemap.xml", to: "seo#sitemap", as: :sitemap, format: false, defaults: { format: :xml }
    get "llms.txt", to: "seo#llms", as: :llms, format: false
    get "llms-full.txt", to: "seo#llms_full", as: :llms_full, format: false
  end

  # Answers on every host: the admin subdomain gets a disallow-all file.
  get "robots.txt", to: "seo#robots", as: :robots, format: false

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Web app manifest, linked from the public layout (app/views/pwa/manifest.json.erb).
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
