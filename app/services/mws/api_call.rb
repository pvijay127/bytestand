module MWS

  # These keys are specific to the seller developer 
  # account owner of this application
  AWS_KEYS = {
    aws_access_key_id: ENV['aws_access_key_id'],
    aws_secret_access_key: ENV['aws_secret_access_key']
  }.freeze

  class ApiCall

    attr_reader :client_opts

    # This parametters are merchant specific keys
    # so by using this keys, the api calls will be
    # scoped to this seller amazon account

    def initialize(merchant_id:,
                   marketplace_id:,
                   auth_token:,
                   aws_access_key_id: AWS_KEYS[:aws_access_key_id],
                   aws_secret_access_key: AWS_KEYS['aws_secret_access_key'] )
      @client_opts = {
        merchant_id: merchant_id,
        marketplace_id: marketplace_id,
        auth_token: auth_token
      }.merge AWS_KEYS
    end
  end
end
