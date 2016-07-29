class HomeController < ApplicationController
  def index
  end

  def download
    @doc = Document.find(params[:id])
    send_file(@doc.path)
  end

  def new
    @url = params[:q]
    @request = Request.create(url: @url)
    if @request.invalid?
      render :index and return
    end
    request_type = determine_type

    if request_type
      @scraper = request_type.new
      @scraper.url = @url
      @doc_id = @scraper.scrape
    else
      flash.now[:error] = "That site is not currently supported."
      render :index and return
    end
    render :index
  end



  private
  def request_params
    params.require(:q)
  end

  ### Formats to support:
  # mobi
  # epub
  # pdf

  ### Domains to support:
  # www.fictionpress.com
  # www.fimfiction.net
  # archiveofourown.org
  # forums.sufficientvelocity.com
  # forums.spacebattles.com
  # forum.questionablequesting.com
  # unsongbook.com
  # worm/pact/twig
  # alicorn
  # alexanderwales.com
  # qntm.org
  # practicalguidetoevil.wordpress.com
  # anarchyishyperbole.com
  # tales of mu

  def determine_type
    @valid_domains = {"fanfiction.net" => FFNScraper}
    @valid_domains.each_key do |domain|
      if @url.include?(domain)
        return @valid_domains[domain]
      else
        return nil
      end
    end
  end
end
