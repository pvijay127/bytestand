# require 'uri'
# require 'peddler'
# require 'mechanize'
# require 'json'
# require 'awesome_print'
# require 'byebug'
#
class ProductScraper
  attr :asin
  attr_reader :product_description, :product_features, :product_pictures
  attr_accessor :logger

  def initialize(asin, logger: nil)
    @asin = asin
    @logger = logger
  end

  def browser
    return @browser if @browser
    @browser = Mechanize.new
    @browser.user_agent = Mechanize::AGENT_ALIASES["Linux Firefox"]
    @browser.set_proxy(ENV['proxy_url'], ENV['proxy_port'], ENV['proxy_username'], ENV['proxy_password'])
    @browser
  end

  def page
    return @page if @page
    logger.info "Get: #{product_url}"
    @page = browser.get(product_url)
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def product_url
    "http://www.amazon.com/gp/product/#{asin}"
  end

  def extract_product_description
    description = page.at('#productDescription')
    description ||= page.search('script').map do |s|
      /iframeContent = "(?<desc>.*)";/ =~ s.content 
      desc
    end.compact.first

    if description
      @product_description = description.text.gsub(/\n[[:blank:]]+/, "\n").gsub(/\n+/, "\n").strip
    else
      @product_description = "We got an empty description"
    end
    @product_description
  end

  def extract_product_features
    features_bullets = page.at("#feature-bullets ul, #feature-bullets-btf .content ul")
    @product_features = if features_bullets.nil?
                  "We got an empty bullet list"
                else
                  features_bullets.text.gsub(/\n[\n\s]+/, "\n")
                end
  end

  def extract_product_pictures
    return @color_images if @color_images
    images_script = page.search('script').to_a.find{ |script| script.text =~ /'colorImages':/ }
    if images_script.nil?
      @color_images = []
    else
      data_obj = JSON(images_script.text.scan(/var data = ({[\w\W]+});/).flatten[0].gsub(/\n/, '').gsub("'", '"'))
      @color_images = data_obj['colorImages']['initial']
      @color_images
    end
  end

  def high_resolution_pictures
    @high_resolution_pictures ||= @color_images.map{ |img| img['hiRes'] }
  end

  def low_resolution_pictures
    @low_resolution_pictures ||= @color_images.map{ |img| img['large']}
  end

  def main_picture
    @main_picture ||= @color_images.find{ |img| img['variant'] == 'MAIN' } || {}
  end

  def best_picture
    @best_picture ||= if main_picture['hiRes']
                        main_picture['hiRes']
                      elsif main_picture['large']
                        main_picture['large']
                      end
  end

  def scrape
    extract_product_description
    extract_product_features
    extract_product_pictures
    product_info
  end

  def product_info
    @info ||= {
      asin: asin,
      description: product_description,
      features: product_features,
      image: best_picture
    }
  end

  def display_product_info
    # page.save_as "#{asin}.html"
    scrape

    puts "Description: #{product_description}"
    puts "Features: #{product_features}"
    puts "Pictures:"

    puts "\t Best Image"
    puts "\t\t#{best_picture}"

    puts "\tMain Picture:"
    ap main_picture
    puts "\t\tHi Res: #{main_picture['hiRes']}"
    puts "\t\tLow Res: #{main_picture['large']}"

    puts "\tHi Resolution:"
    high_resolution_pictures.each do |pic|
      puts "\t\t#{pic}"
    end

    puts "\tHi Low:"
    low_resolution_pictures.each do |pic|
      puts "\t\t#{pic}"
    end
  end
end

