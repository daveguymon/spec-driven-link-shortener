Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "short_links#new"
  get "links", to: "short_links#new", as: :links_page
  resources :links, only: [:create], controller: "short_links"
  get "/:alias", to: "short_links#show", as: :short_link
end
