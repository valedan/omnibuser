class ProxiesExhausted < StandardError; end

class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue, :agent, :story, :target, :offset

  USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:62.0) Gecko/20100101 Firefox/62.0",
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:63.0) Gecko/20100101 Firefox/63.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
  ]

  def self.perform(request_id)
    begin
      request = Request.find(request_id)
      story = self.new(url: request.url, request: request, target: request.target).scrape
      request.update!(story_id: story.id)
      Resque.enqueue(DelayedBuilder, request.id)
    rescue Exception => e
      request.update(complete: true, status: e)
      raise e
    end
  end

  def scrape
    @base_url = get_base_url
    raise ScraperError, "Cannot find a story at url provided. Please recheck the url." unless @base_url
    @proxies = Proxy.all.to_a
    @agent = Mechanize.new
    @agent.user_agent = "Omnibuser 1.2 www.omnibuser.com"
    get_story
    @story
  end

  def get_page(url)
    puts "Retrieving page #{url}"
    tries = 5
    @proxies.shuffle!
    proxy_index = 0
    begin
      if self.class == FFNScraper && @proxies.length > 0
        proxy = @proxies[proxy_index]
        @agent.set_proxy(proxy.ip, proxy.port, proxy.username, proxy.password)
        @agent.user_agent = USER_AGENTS.sample
        response = @agent.get(url)
        proxy.update!(successful_request_count: proxy.successful_request_count + 1, last_successful_request: Time.now)
        response
      else
        @agent.get(url)
      end
    rescue Exception => e
      if self.class == FFNScraper && @proxies.length > 0
        proxy = @proxies[proxy_index]
        proxy.increment!(:failed_request_count)
        proxy_index += 1
      end
      tries -= 1
      if tries > 0
        if self.class == FFNScraper && @proxies.length > 0
          Rollbar.warning(e, "FFN connection failure for proxy #{proxy.ip}")
        end
        retry
      else
        if self.class == FFNScraper && @proxies.length > 0
          raise ProxiesExhausted.new("Could not connect to #{request.url}")
        else
          raise e
        end
      end
    end
  end

  def queue_page(url)
    #make this dynamic+generic and use it for images too
    delay = 1.0
    @target.reload
    if Time.now - @target.last_access > delay
      @target.update!(last_access: Time.now)
      get_page(url)
    else
      sleep(delay - (Time.now - @target.last_access) + rand)
      queue_page(url)
    end
  end

  def extract_images(content)
    content.search('img').each do |img|
      next if img['src'].blank?
      duplicate = @story.has_image(absolute_url(img['src'], @page.uri))
      if duplicate
        img['src'] = "#{duplicate.name}"
      else
        image = scrape_image(absolute_url(img['src'], @page.uri))
        img['src'] = "#{image}"
      end
    end
    content
  end

  def scrape_image(url, cover: false)
    begin
      puts "Retrieving image at #{url}"
      sleep(1)
      src = queue_page(url)
    rescue Exception => e
      puts e
    end
    if src&.class == Mechanize::Image
      image = Image.create(story_id: @story.id,
                           extension: src['content-type'].split('/')[-1],
                           source_url: url,
                           cover: cover)
      background_color = @target_data['image_background']
      unless url.include?('clear.png')
        begin
          src.save("#{image.path}.temp")
          image.compress(background_color)
        rescue Exception => e
          puts e
        end
      end
      src.save(image.path) unless File.exist?(image.path)
      image.upload
    end
    image&.name
  end

  def absolute_url(url, reference)
    url = url.split('#')
    unless url[0]&.start_with?('http') || url[0].blank?
      url[0] = "/#{url[0]}" unless url[0].start_with?('/')
      new_uri = URI::Generic.build({scheme: reference.scheme,
                                    host: reference.host,
                                    path: url[0].split('?')[0],
                                    query: url[0].split('?')[1],
                                    fragment: url[1]})
    end
    if new_uri
      new_uri.to_s
    else
      url.join('#')
    end
  end

  def absolutify_urls(content)
    content.search('a').each do |a|
      next if a['href'].blank?
      a['href'] = absolute_url(a['href'], @page.uri)
    end
    content
  end

  def filter_nodes(nodeset, filters)
    filters&.each do |filter|
      nodeset.search(filter).each{|n| n.remove}
    end
    nodeset
  end

end
