class HomeController < ApplicationController
  def index
  end

  def new
    @request = Request.create(url: params[:q])
    if @request.invalid?
      render :index and return
    end
    request_type = @request.determine_type

    # ask Request if domain is valid, and which Scraper class to use
    if request_type
      @scraper = request_type.new
      @scraper.url = params[:q]
      message = @scraper.scrape
    else
      flash.now[:error] = "That site is not currently supported."
      render :index and return
    end

    flash.now[:notice] = message
    render :index
  end

  private
  def request_params
    params.require(:q)
  end
end
