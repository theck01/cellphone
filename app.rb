require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require './lib/sinatra/partials'
require './lib/sinatra/javascripts'
require './lib/sinatra/styles'

class AutoExpApp < Sinatra::Base

  register Sinatra::ConfigFile
  helpers Sinatra::Partials
  helpers Sinatra::Javascripts
  helpers Sinatra::Styles

  config_file 'config.yml'

  # ROUTES

  get '/' do
    haml :index
  end
  
  # run app if file is executed directly
  run! if app_file ==$0
end
