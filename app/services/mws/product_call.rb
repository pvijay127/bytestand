module MWS
  # This class continue the process of grabbing the product details
  # before this starts its work, a list of products asins should be 
  # available, and this can be done by using the ReportCall which get
  # the products asins and some other details.
  class ProductCall < ApiCall

    class << self
      attr_reader :config

      def setup
        @config ||= OpenStruct.new
        yield @config if block_given?
        @config
      end

      def client
        @client ||= MWS::Products::Client.new(client_opts)
      end

      def client_opts
        @client_opts ||= AWS_KEYS.merge(config.api_keys)
      end

      def get_products_details(asins)
        asins = Array(asins)
        @products_details = client.get_matching_product_for_id('ASIN', *asins).parse
        @products_details.map do |item|
          begin
            details = item['Products']['Product']
            details.merge!(asin: item['Id'])
            normalize_product_details(details)
          rescue => e
            byebug
          end
        end
      end

      def normalize_product_details details
        product = {}
        item_attrs = details['AttributeSets']['ItemAttributes']
        product[:asin] = details[:asin]
        product[:vendor] = item_attrs['Brand']
        product[:product_type] = item_attrs['ProductGroup']
        product[:color] = item_attrs['Color']
        # Those will be downloaded by the scraper
        # product.bullets = item_attrs[:bullets]
        # product.image = item_attrs[:image]
        if item_attrs['PackageDimensions']
          pdim = normalize_package_dimensions(item_attrs['PackageDimensions'])
          product[:package_height] = pdim[:height]
          product[:package_length] = pdim[:length]
          product[:package_width]  = pdim[:width]
          product[:weight]         = pdim[:weight]
        end
        product[:size] = item_attrs['Size']
        product[:compare_at_price] = item_attrs["ListPrice"].try(:[], "Amount")
        product
      end

      def normalize_package_dimensions(package_dimensions)
        pdim = {}
        %w(Height Width Length Weight).each do |prop|
          if Hash === package_dimensions[prop]
            pdim[prop.downcase.to_sym] = package_dimensions[prop].values.join(' ')
          end
        end
        pdim
      end
    end

  end
end
