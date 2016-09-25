class StaticController < ApplicationController

  def about
    @title = "Omnibuser | About"
    @canonical = "http://omnibuser.com/about"
  end

  def contact
    @title = "Omnibuser | Contact"
    @canonical = "http://omnibuser.com/contact"
  end
end
