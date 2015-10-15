module MWS
  # This class continue the process of grabbing the product details
  # before this starts its work, a list of products asins should be 
  # available, and this can be done by using the ReportCall which get
  # the products asins and some other details.
  class ProductCall < ApiCall

    class << self
      attr_accessor :config, :logger

      def setup
        @config ||= OpenStruct.new
        yield @config if block_given?
        @logger = config.logger || Logger.new(STDOUT)
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
        @products_details = Array(client.get_matching_product_for_id('ASIN', *asins).parse)
        @products_details.map do |item|
          begin
            details = item['Products']['Product']
            details.merge!(asin: item['Id'])
            normalize_product_details(details)
          rescue => e
            logger.fatal e.message
            logger.fatal e.backtrace.join("\n")
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
        if item_attrs['PackageDimensions']
          pdim = normalize_package_dimensions(item_attrs['PackageDimensions'])
          product[:package_height] = pdim[:height]
          product[:package_length] = pdim[:length]
          product[:package_width]  = pdim[:width]
          product[:weight]         = pdim[:weight]
        end
        product[:size] = item_attrs['Size']
        product[:compare_at_price] = item_attrs["ListPrice"].try(:[], "Amount")
        # Here it will get the parent asin, but until here the
        # parent_id is not set yet. So it has to be set later
        product['parent_asin'] = extract_variant_parent_asin(details['Relationships'])

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

      def extract_variant_parent_asin(relationships)
        return unless (relationships && relationships['VariationParent'])
        relationships['VariationParent']['Identifiers']['MarketplaceASIN']['ASIN']
      end
    end

  end
end
