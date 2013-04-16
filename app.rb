require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'json'

class AutoExpApp < Sinatra::Base

  register Sinatra::ConfigFile
  config_file 'config.yml'
  
  # SERVER STATE VARIABLES
  @@dose = 5 #ml
  @@experiment_done = false
  @@experiment_setup = {}
  @@experiment_settings = {}
  @@img_prefix = 'test'
  @@img_thread = nil
  @@recent_img_name = '.placeholder.jpg'
  @@syringe_size = 10 #ml, standard syringe
  @@threshold = 128 #pixel intensity

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
