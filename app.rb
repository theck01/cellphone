require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'json'

class AutoExpApp < Sinatra::Base

  register Sinatra::ConfigFile
  config_file 'config.yml'
  
  # SERVER STATE VARIABLES
  @@recent_img_name = '.placeholder.jpg'
  @@img_thread = nil

  # ROOT ROUTE
  get '/' do
    @page = :index
    haml :layout
  end
end

# load helpers, models, and routes
require './helpers/init'
require './routes/init'
require './models/init'
