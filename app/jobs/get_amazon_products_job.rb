class GetAmazonProductsJob < ActiveJob::Base
  queue_as :reports

  # We need the amazon_account_id here because this jobs are run by Sidekiq
  # and there we have no mean to get the amazon account to which the products
  # that we get belongs_to
  def perform(api_keys: , report_request_id: nil, amazon_account_id: )
    # Send a report request
    report = MWS::ReportCall.new(api_keys: api_keys, request_id: report_request_id)

    # if report_request_id is nil, this means we did not send the report request
    # yet. but if its present just go ahead an check for the status
    unless report_request_id.present?
      report.submit_request(report_type: '_GET_MERCHANT_LISTINGS_DATA_')
    end

    # every time we check status and the report is not ready
    # just schedule a job to perform the check again
    report_not_ready_callback = proc do |rep| 
      logger.info "Report not yet done. Status(#{rep.status})"
      GetAmazonProductsJob.set(wait: 30.seconds).perform_later(api_keys: api_keys,
                                                               report_request_id: rep.request_id,
                                                               amazon_account_id: amazon_account_id)
    end

    # once the report is ready, extract the products asins list
    # and schedule jobs to get products details
    report_ready_callback = proc do |rep|
      logger.info "Report ready. Status(#{rep.status})."
      # this will get the first list of product details
      products_details = rep.get_products_details
      products_details.each_with_index do |product_details, idx|
        product = Product.find_or_initialize_by(asin: product_details[:asin],
                                                amazon_account_id: amazon_account_id)
        product.attributes = product_details
        product.save
      end
      products_details.map!{ |pd| pd[:asin] }.each_slice(5).with_index do |asins, idx|
        wait_period = idx * 3
        GetProductsDetailsJob.set(wait: wait_period.seconds).perform_later(api_keys: api_keys,
                                                                           asins: asins)
      end
    end
    # check for report request status
    report.check_status(ready_callback: report_ready_callback, not_ready_callback: report_not_ready_callback)
  rescue Excon::Errors => e
    log_error e, amazon_account_id
  end

  def log_error e, id
    logger.fatal e.message
    logger.info "Amazon Account Id : #{id}"
    logger.fatal e.backtrace.join("\n")
  end

  def logger
    Sidekiq::Logging.logger
  end
end
