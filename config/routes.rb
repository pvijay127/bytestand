require 'sidekiq/web'

Rails.application.routes.draw do
  root :to => 'home#index'
  mount ShopifyApp::Engine, at: '/'
  resource :amazon_account, only: [:new, :create, :edit, :update]
  mount Sidekiq::Web => '/sidekiq'
end

# == Route Map
#
#      Prefix Verb URI Pattern Controller#Action
#        root GET  /           home#index
# shopify_app      /           ShopifyApp::Engine
#
# Routes for ShopifyApp::Engine:
#                 login GET  /login(.:format)                 sessions#new
#          authenticate POST /login(.:format)                 sessions#create
# auth_shopify_callback GET  /auth/shopify/callback(.:format) sessions#callback
#                logout GET  /logout(.:format)                sessions#destroy
#
