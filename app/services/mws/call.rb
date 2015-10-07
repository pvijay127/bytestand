module MWS
  class Call
    AWS_KEYS = {
      aws_access_key_id: ENV['aws_access_key_id'],
      aws_secret_access_key: ENV['aws_secret_access_key']
    }

    attr_reader :aws_seller_account_keys, :reports_list

    alias clients_opts aws_seller_account_keys

    def initialize(merchant_id:, marketplace_id:, auth_token:)
      @aws_seller_account_keys = {
        merchant_id: merchant_id,
        marketplace_id: marketplace_id,
        auth_token: auth_token
      }.merge AWS_KEYS
      @reports_list = []
    end

    def get_products_list
      return @products if @products
      # submit a RequestReport operation
      # and parse response and extract ReportRequestId
      report = MWS::Report.new(clients_opts)
      reports_list.push(report)
      report.submit_report(report_type: '_GET_MERCHANT_LISTINGS_DATA_')
      # submit GetReportRequestList operation
      # Parse response and read report status
      report.check_status do |rep|
        rep.get_report_data
      end
      @products = report.data.map(&:to_h)
    end
  end
end
