class Tracker
  class << self
    def redis(&block)
      Sidekiq.redis(&block)
    end

    def start_tracking_pull(merchant_id)
      redis do |con|
        return con.set("pulling#{ merchant_id }", true)
      end
    end

    def pulling_amazon_products?(merchant_id)
      redis do |con|
        return !!con.get("pulling#{ merchant_id }")
      end
    end

    def start_tracking_jobs merchant_id
      redis{ |con| con.set("product_jobs_count_for_#{ merchant_id }", 0) }
    end

    def stop_tracking_jobs merchant_id
      redis do |con|
        if jobs_count_for(merchant_id).zero?
          begin
            Product.set_products_parents
          ensure
            con.del("pulling#{ merchant_id }")
          end
        end
      end
    end

    private
    def jobs_count_for(merchant_id)
      redis do |con|
        return con.get("product_jobs_count_for_#{ merchant_id }").to_i
      end
    end
  end
end
