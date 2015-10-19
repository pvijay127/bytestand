require 'sidekiq/web'

Rails.application.routes.draw do
  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  resource :amazon_account, only: [:new, :create, :edit, :update]
  resources :amazon_products, only: nil do
    put :pull, on: :collection
    post :push, on: :collection
  end
  mount Sidekiq::Web => '/sidekiq'
end

# == Route Map
#
#               Prefix Verb   URI Pattern                         Controller#Action
#                 root GET    /                                   home#index
#          shopify_app        /                                   ShopifyApp::Engine
#       amazon_account POST   /amazon_account(.:format)           amazon_accounts#create
#   new_amazon_account GET    /amazon_account/new(.:format)       amazon_accounts#new
#  edit_amazon_account GET    /amazon_account/edit(.:format)      amazon_accounts#edit
#                      PATCH  /amazon_account(.:format)           amazon_accounts#update
#                      PUT    /amazon_account(.:format)           amazon_accounts#update
# pull_amazon_products PUT    /amazon_products/pull(.:format)     amazon_products#pull
# push_amazon_products PUT    /amazon_products/push(.:format)     amazon_products#push
#      amazon_products GET    /amazon_products(.:format)          amazon_products#index
#                      POST   /amazon_products(.:format)          amazon_products#create
#   new_amazon_product GET    /amazon_products/new(.:format)      amazon_products#new
#  edit_amazon_product GET    /amazon_products/:id/edit(.:format) amazon_products#edit
#       amazon_product GET    /amazon_products/:id(.:format)      amazon_products#show
#                      PATCH  /amazon_products/:id(.:format)      amazon_products#update
#                      PUT    /amazon_products/:id(.:format)      amazon_products#update
#                      DELETE /amazon_products/:id(.:format)      amazon_products#destroy
#          sidekiq_web        /sidekiq                            Sidekiq::Web
#
# Routes for ShopifyApp::Engine:
#                 login GET  /login(.:format)                 sessions#new
#          authenticate POST /login(.:format)                 sessions#create
# auth_shopify_callback GET  /auth/shopify/callback(.:format) sessions#callback
#                logout GET  /logout(.:format)                sessions#destroy
#
