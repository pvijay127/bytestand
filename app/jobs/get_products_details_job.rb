class GetProductsDetailsJob < ActiveJob::Base
  queue_as :products

  def perform(api_keys: {}, asins: )
    logger.info "Getting products details: ASINs => #{asins.inspect}"
    MWS::ProductCall.setup do |config|
      config.api_keys = api_keys 
      config.logger = logger
    end
    products_details = MWS::ProductCall.get_products_details(asins)
    products_details.each do |product_details|
      product = Product.find_or_initialize_by(asin: product_details[:asin])
      product_details.merge!(ProductScraper.new(product_details[:asin], logger: logger).scrape)
      product_details.delete_if{ |k,v| v.blank? }
      product.attributes = product_details
      product.save
    end
    # This will not stop tracking jobs
    # but instead it just check if there still some jobs running
    # if not delete the flag
    Tracker.stop_tracking_jobs(api_keys[:merchant_id])
    # sleep 1 second to make sure that a request has been restored
    # the get_matching_product_for_id request has a quota of 20
    # and a restore rate of 5 products per second
    sleep 1

  rescue Excon::Errors::Error => e
    log_error e, asins
    sleep 10
    retry
  rescue => e
    log_error(e, asins)
  end

  def log_error e, asins
    logger.fatal e.message
    logger.info "ASINs: #{asins.inspect}"
    logger.fatal e.backtrace.join("\n")
  end

  def logger
    Sidekiq::Logging.logger
  end
end
