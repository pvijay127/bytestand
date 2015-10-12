class GetAmazonProductsJob < ActiveJob::Base
  queue_as :reports

  # We need the amazon_account_id here because this jobs are run by Sidekiq
  # and there we have no mean to get the amazon account to which the products
  # that we get belongs_to
  def perform(amazon_account_id: , report_request_id: nil)
    logger.info "Requesting amazon products list for:\
    amazon_account_id: #{amazon_account_id}
    "
    amazon_account = AmazonAccount.find(amazon_account_id)
    # Send a report request
    report = MWS::ReportCall.new(api_keys: amazon_account.api_keys, request_id: report_request_id)

    # if report_request_id is nil, this means we did not send the report request
    # yet. but if its present just go ahead an check for the status
    unless report_request_id.present?
      report.submit_request(report_type: '_GET_MERCHANT_LISTINGS_DATA_')
    end

    # every time we check status and the report is not ready
    # just schedule a job to perform the check again
    report_not_ready_callback = proc do |rep| 
      logger.info "Report not yet done. Status(#{rep.status})"
      # The maximum request quota of get_report_request_list is 10
      # and the restore rate is of 1 request per 45 seconds
      # So we should wait for some time before we send the request
      # again, first because of the limit, and second because the
      # report takes time to be done, so 30 seconds is a good. It's
      # not too long for the user to wait and not very frequent so
      # that we do not run out of requests early.
      GetAmazonProductsJob.set(wait: 30.seconds).perform_later(amazon_account_id: amazon_account_id, 
                                                               report_request_id: rep.request_id)
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

      # Filter out the products asins that have been updated
      # in the last hour
      asins_to_reject = Product.where(updated_at: [1.hour.ago..DateTime.now],
                                      amazon_account_id: amazon_account_id).pluck(:asin)
      asins = products_details.map!{ |pd| pd[:asin] } - asins_to_reject
      if asins.blank?
        logger.info("task skipped.")
        logger.info("products of amazon_account #{amazon_account_id} are up to date.")
      else
        asins.each_slice(5).with_index do |asins, idx|
          wait_period = idx * 5
          GetProductsDetailsJob.set(wait: wait_period.seconds).perform_later(api_keys: amazon_account.api_keys,
                                                                             asins: asins)
        end
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
