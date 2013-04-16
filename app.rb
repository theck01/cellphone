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
  @@experiment_setup = { title: 'test' }
  @@experiment_settings = { 
    dosage: 1.0, hours: 1.0, minutes: 0, syringe: 25.0, threshold: 128.0
  }
  @@img_prefix = 'test'
  @@img_thread = nil
  @@recent_img_name = '.placeholder.jpg'
  @@syringe_size = 10 #ml, standard syringe
  @@threshold = 128 #pixel intensity

  # ROOT ROUTE
  get '/' do
    if !@@img_thread && !@@experiment_done
      redirect '/experiment/setup' 
    elsif @@img_thread
      redirect '/experiment/show' 
    else
      @page = :index
      haml :layout
    end
  end
end

# load helpers, models, and routes
require './helpers/init'
require './routes/init'
require './models/init'
