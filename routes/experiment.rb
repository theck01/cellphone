class AutoExpApp < Sinatra::Base

  # start experiment, if one is not already running
  get '/experiment/begin' do
    unless @@img_thread

      #new image capture worker process
      @@img_thread = Thread.new do
        while true do

          # capture image from microscope
          recent_img_name = get_image 'test', './public/assets/imgs'
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

  post '/experiment/form_test' do
    params.to_s
  end

  #render the settings page
  get '/experiment/settings' do
    @page = 'experiment/settings'
    haml :layout
  end

  # render the setup page
  get '/experiment/setup' do
    scripts :experiment_setup
    styles :experiment_setup
    @page = 'experiment/setup'
    haml :layout
  end

  # render the experiment viewing page
  get '/experiment/show' do
    scripts :experiment_show, :highcharts
    @page = 'experiment/show'
    @start_img = @@recent_img_name
    haml :layout
  end
end
