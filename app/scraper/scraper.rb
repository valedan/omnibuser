
class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue, :agent, :story, :target, :offset

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
    @agent = Mechanize.new
    @agent.user_agent = "Omnibuser 1.2 www.omnibuser.com"
    get_story
    @story
  end

  def get_page(url)
    puts "Retrieving page #{url}"
    tries = 3
    begin
      @agent.get(url)
    rescue Exception => e
      if tries > 0
        tries -= 1
        retry
      else
        raise e
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
      src = @agent.get(url)
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
    byebug
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
