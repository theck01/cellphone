require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'json'

class AutoExpApp < Sinatra::Base

  register Sinatra::ConfigFile
  config_file 'config.yml'
  
  # SERVER STATE VARIABLES, with default values
  @@dose = 0 #ul
  @@end_time = nil
  @@experiment_done = false
  @@experiment_paused = false
  @@experiment_setup = { file_prefix: 'test' }
  @@experiment_settings = { 
    dosage: 1.0, hours: 1.0, minutes: 0, syringe: 25.0, threshold: 0
  }
  @@img_prefix = 'test'
  @@img_thread = nil
  @@recent_img_name = '.placeholder.jpg'
  @@syringe_size = 10 #ml, standard syringe

  # before all routes check to see if experiment has expired. If so
  # kill the worker thread
  before '/*' do
    if @@img_thread && @@experiment_done
      @@img_thread.terminate
      @@img_thread = nil
      package_results @@experiment_setup[:file_prefix]
    end
  end


  # ROOT ROUTE
  get '/' do
    if !@@img_thread && !@@experiment_done
      redirect '/experiment/setup' 
    elsif @@img_thread
      redirect '/experiment/show' 
    else
      redirect '/experiment/results'
    end
  end
end

# load helpers, models, and routes
require './helpers/init'
require './routes/init'
