Rails.application.routes.draw do
  devise_for :users
  root "static_pages#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/patients/:id", to: "patients#show"
  get "/wwwwhaaat/:is_this/:franks_red", to: "static_pages#boom", as: "hell_yeah"
end
