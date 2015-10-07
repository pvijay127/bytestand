module MWS
  class Report
    attr_accessor :id, :request_id, :status, :client_opts, :data

    def initialize client_opts
      @client_opts = client_opts
    end

    def client
      @client ||= MWS::Reports::Client.new client_opts
    end

    # send a request_report
    # parses the result
    # and save ReportRequestId
    def submit_report(report_type:)
      aws_response = client.request_report report_type
      @request_id = aws_response.parse['ReportRequestInfo']['ReportRequestId']
    end

    # check status and call block when status is _DONE_
    def check_status(&block)
      while true
        resp = client.get_report_request_list(report_request_id_list:
                                              Array(request_id)).parse
        @status = resp['ReportRequestInfo']['ReportProcessingStatus']
        puts @status
        if @status == '_DONE_'
          @id = resp['ReportRequestInfo']['GeneratedReportId']
          block.call(self) if block_given?
          break
        end
        puts 'sleeping'
        sleep 30
      end
    end

    def get_report_data
      @data = client.get_report(self.id).parse
    end
  end
end
