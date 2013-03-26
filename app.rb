require 'sinatra/base'
require 'sinatra/config_file'
require 'haml'
require 'json'
require './lib/sinatra/partials'
require './lib/sinatra/javascripts'
require './lib/sinatra/styles'
require './lib/sinatra/imagecapture'

class AutoExpApp < Sinatra::Base

  register Sinatra::ConfigFile
  helpers Sinatra::Partials
  helpers Sinatra::Javascripts
  helpers Sinatra::Styles
  helpers Sinatra::ImageCapture

  config_file 'config.yml'
  
  # CLASS STATUS VARIABLES
  @@exp_running = false
  @@img_name = nil


  # ROUTES

  get '/' do
    haml :index
  end

  # start experiment, if one is not already running
  get '/begin' do
    unless @@exp_running

      #new image capture worker process
      Thread.new do
        while true do
          img_name = get_image 'test', './imgs'
          @@img_name = img_name
        end
      end

      @@exp_running = true
    end

    redirect :experiment
  end

  # observe the experiment currently running
  get '/experiment' do
    @@img_name
  end

  # request most recent image captured from the microscope
  get '/recent_img' do
    send_file @@img_name
  end

  # request dosage and syringe information as json
  get '/dose' do
    content_type :json
    { dose: 1, syringe_size: 10 }.to_json
  end

  # run app if file is executed directly
  run! if app_file ==$0
end
