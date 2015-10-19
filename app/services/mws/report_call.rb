module MWS
  # This starts the process to grabb all the seller's products
  # It starts by sending a report request, keeps checking for
  # the status of the report, and when done, it extracts the 
  # products details that are available in the response.
  # To complete the product details the process should be 
  # continued by the ProductCall.
  class ReportCall < ApiCall
    attr_accessor :id, :request_id, :status, :client_opts, :data

    def initialize request_id: nil, api_keys: {}
      super api_keys
      @request_id = request_id
    end

    def client
      @client ||= MWS::Reports::Client.new(client_opts)
    end

    # send a request_report
    # parses the result
    # and save ReportRequestId
    def submit_request(report_type:)
      aws_response = client.request_report report_type
      @request_id = aws_response.parse['ReportRequestInfo']['ReportRequestId']
    end

    # check status and call block when status is _DONE_
    def check_status(not_ready_callback: nil, ready_callback: nil)
      unless not_ready_callback.blank? || not_ready_callback.respond_to?(:call) 
        fail 'not_ready_callback should be a proc, lambda or a method object'\
      end
      unless ready_callback.blank? || ready_callback.respond_to?(:call)
        fail 'ready_callback should be a proc, lambda or a method object'\
      end
      resp = client.get_report_request_list(report_request_id_list:
                                            Array(request_id)).parse
      @status = resp['ReportRequestInfo']['ReportProcessingStatus']
      if @status == '_DONE_'
        @id = resp['ReportRequestInfo']['GeneratedReportId']
        ready_callback.call(self) if ready_callback.present?
      else
        not_ready_callback.call(self) if not_ready_callback.present?
      end
    end

    # This will get the first list of product details
    def get_products_details
      unless @products_details
        @products_details = client.get_report(self.id).parse.map(&:to_h)
      end
      @products_details.map!{ |pd| normalize_product_details(pd) }
    end

    def normalize_product_details(product_details)
      if !product_details['quantity'].to_i.zero?
        byebug
      end
      {
        asin: product_details['asin1'],
        title: product_details['item-name'],
        description: product_details['item-description'],
        seller_sku: product_details['seller-sku'],
        price: product_details['price'],
        quantity: product_details['quantity']
      }
    end

  end
end
