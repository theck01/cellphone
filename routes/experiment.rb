class AutoExpApp < Sinatra::Base
  
  # start experiment, if one is not already running
  get '/experiment/begin' do
    unless @@img_thread

      #new image capture worker process
      @@img_thread = Thread.new do
        while true do

          # capture image from microscope
          recent_img_name = get_image @@experiment_setup[:file_prefix], './public/assets/imgs'
          recent_img_name = File.basename recent_img_name

          # try to request histogram from image from histogrammer server
          begin
            url = "http://#{settings.histogrammer_ip}:3000/api/histogram"
            response = RestClient.get "#{url}/#{recent_img_name}"
            @histogram = JSON.parse(response.body)['histogram']
          rescue Errno::ECONNREFUSED
            @histogram = Array.new(256,0)
          end

          # save a histogram, valid or zeros
          path = "./public/assets/histograms"
          histname = "histogram_of_#{File.basename(recent_img_name, '.jpg')}"
          File.open("#{path}/#{histname}.csv", "w") do |file|
            file.puts @histogram.to_json
          end

          # set recent image name variable last, to
          # ensure histogram file is ready
          @@recent_img_name = recent_img_name
        end
      end
    end

    redirect 'experiment/show'
  end

  # end the experiment, if one is running
  get '/experiment/end' do
    if @@img_thread
      @@img_thread.terminate
      @@img_thread = nil
    end

    redirect '/'
  end

  #render the settings page
  get '/experiment/settings' do
    scripts :experiment_settings
    @page = 'experiment/settings'
    @settings = @@experiment_settings
    haml :layout
  end

  # save values from the settings page
  post '/experiment/settings' do
    params.each{ |k,v| @@experiment_settings[k.to_sym] = v.to_f }
    puts @@experiment_settings.to_s
    redirect '/experiment/begin'
  end

  # render the setup page
  get '/experiment/setup' do
    scripts :experiment_setup
    @page = 'experiment/setup'
    haml :layout
  end
  
  # save values from the setup page
  post '/experiment/setup' do
    params.each{ |k,v| @@experiment_setup[k.to_sym] = v }
    @@experiment_setup[:file_prefix] = @@experiment_setup[:title].downcase.gsub(/[^a-z\s_\-]/, '').gsub(/\s/, '-')
    puts @@experiment_setup.to_s
    redirect '/experiment/settings'
  end

  # render the experiment viewing page
  get '/experiment/show' do
    scripts :experiment_show, :highcharts
    @page = 'experiment/show'
    @start_img = @@recent_img_name
    @settings = @@experiment_settings
    haml :layout
  end
end
