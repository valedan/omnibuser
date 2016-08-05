
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
    begin
      @scraper = Scraper.create(@url)
      @doc_id = @scraper.scrape
    rescue ScraperError => e
      flash.now[:error] = e.message
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
end
