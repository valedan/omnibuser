require "resque_web"

Rails.application.routes.draw do
  root 'home#index'
  post '/',              to: 'home#new'
  get  '/requests/:id',  to: 'home#status'
  post '/scrape/:id',    to: 'home#scrape'

  get 'about', to: 'static#about'
  get 'contact', to: 'static#contact'

  mount ResqueWeb::Engine => "/resque_web"
end
