
class HomeController < ApplicationController
  require 'open-uri'

  def index
    @canonical = "http://omnibuser.com"
  end

  def status
    request = Request.find(params[:id])
    respond_to do |format|
      format.json {render json: request.to_json, status: :ok}
    end
  end

  def scrape
    puts "begin scrape"
    respond_to do |format|
      begin
        @request = Request.find(params[:id])
        @request.update(complete: false, status: "In Progress")
        @request.scrape
        format.json {render json: @request, status: :ok}
      rescue ScraperError => e
        @request.update(complete: true, status: e)
        Rollbar.error(e)
        format.json {render json: @request, status: 422}
      rescue Exception => e
        @request.update(complete: true, status: "Sorry, something went wrong.")
        Rollbar.error(e)
        format.json {render json: @request, status: 422}
      end
    end
  end

  def new
    respond_to do |format|
      begin
        @request = Request.create(url: params[:q], extension: params[:ext], strategy: params[:strategy], recent_number: params[:recent_number], status: "Initializing")
        format.json {render json: @request.to_json, status: :created}
      rescue Exception => e
        @request = Request.new
        @request.status = e
        @request.complete = true
        Rollbar.error(e)
        format.json {render json: @request, status: 422}
      end
    end
  end

  private
  def request_params
    params.require(:q, :ext, :strategy, :recent_number)
  end

end
