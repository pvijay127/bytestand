ShopifyApp.configure do |config|
  config.api_key = ENV['api_key']
  config.secret = ENV['api_secret']
  config.redirect_uri = ENV['redirect_url']
  config.scope = "read_products, write_products"
  config.embedded_app = true
end
