class AutoExpApp < Sinatra::Base

  # start experiment, if one is not already running
  get '/experiment/begin' do
    unless @@img_thread || @@experiment_done

      #new image capture worker process
      @@img_thread = Thread.new do
        while true do

          # capture image from microscope
          recent_img_name = get_image @@experiment_setup[:file_prefix], './public/assets/imgs'
          recent_img_name = File.basename recent_img_name

          # try to request histogram from image from histogrammer server
          begin
            url = "http://#{settings.histogrammer_ip}:#{settings.histogrammer_port}/api/histogram"
            response = RestClient.get "#{url}/#{recent_img_name}"
            @histogram = JSON.parse(response.body)['histogram']
          rescue Errno::ECONNREFUSED
            @histogram = Array.new(256,0)
          end

          # save a histogram, valid or zeros
          path = "./logs/histograms"
          histname = "histogram_of_#{File.basename(recent_img_name, '.jpg')}"
          File.open("#{path}/#{histname}.csv", "w") do |file|
            file.puts @histogram.to_json
          end

          # determine if new dose should be automatically administered
          avg = @histogram.each_with_index.map{ |x,i| x*i }.reduce(:+)
          should_dose = avg < @@experiment_settings[:threshold]
          should_dose &&= !@@experiment_done
          if @@prev_dose
            should_dose &&= (Time.now - @@prev_dose) > @@experiment_settings[:interdose]
          end

          if should_dose
            @@dose = @@experiment_settings[:dosage]
            @@prev_dose = Time.now
            puts "Drug dose for administration set automatically"
            log_dose dosage_ul: @@dose, requested_automatically: true
          end

          # set recent image name variable last, to
          # ensure histogram file is ready
          @@recent_img_name = recent_img_name

          # check if runtime elapsed
          if @@end_time && (@@end_time - Time.now) < 0
            @@experiment_done = true
          end

          # stop the thread if the experiment should be paused
          Thread.stop if @@experiment_paused || @@experiment_done
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
      package_results @@experiment_setup[:file_prefix]
    end

    @@experiment_done = true
    redirect '/'
  end

  # render the download results page
  get '/experiment/results' do
    @page = 'experiment/results'.to_sym
    @zipname = "#{@@experiment_setup[:file_prefix]}.zip"
    haml :layout
  end

  #render the settings page
  get '/experiment/settings' do
    scripts :experiment_settings

    time_diff = if @@experiment_done
      0
    elsif @@end_time
      @@end_time - Time.now
    else
      60*60
    end

    @hours_left = time_diff.div(60*60).floor
    @minutes_left = time_diff.modulo(60*60).div(60).floor
    @page = 'experiment/settings'

    @settings = @@experiment_settings
    haml :layout
  end

  # save values from the settings page
  post '/experiment/settings' do
    params.each{ |k,v| @@experiment_settings[k.to_sym] = v.to_f }
    @@end_time = Time.now + (@@experiment_settings[:hours]*60*60 + @@experiment_settings[:minutes]*60)
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
    log_setup @@experiment_setup
    redirect '/experiment/settings'
  end

  # render the experiment viewing page
  get '/experiment/show' do
    scripts :experiment_show, :highcharts
    styles :experiment_show
    @page = 'experiment/show'
    @paused = @@experiment_paused && !@@experiment_done
    @start_img = @@recent_img_name
    @settings = @@experiment_settings
    @title = @@experiment_setup[:title]
    haml :layout
  end
end
