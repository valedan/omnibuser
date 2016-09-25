class StaticController < ApplicationController

  def about
    @title = "Omnibuser | About"
  end

  def contact
    @title = "Omnibuser | Contact"
  end
end
