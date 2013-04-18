class AutoExpApp < Sinatra::Base

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json
    
    # give a zero dose if the experiment is over
    @@dose = 0 if @@experiment_done

    if @@dose != 0
      puts 'Dose administered' 
      log_dose dosage_ul: @@dose, administered: true
    end

    dose = @@dose
    @@dose = 0
    { dose: dose.to_s, syringe_size: @@experiment_settings[:syringe].to_s }.to_json
  end

  # request the histogram of the last saved image
  get '/api/histogram' do
    content_type :json

    path = "./logs/histograms"
    if @@recent_img_name == '.placeholder.jpg'
      histname = '.histogram_of_placeholder'
    else
      histname = "histogram_of_#{File.basename(@@recent_img_name, '.jpg')}"
    end

    File.open("#{path}/#{histname}.csv") do |file|
      @histogram = JSON.parse(file.gets)
    end

    # statistics on the histogram
    weighted_freq = @histogram.each_with_index.map{ |x,i| x*i }
    avg = weighted_freq.reduce(:+)
    median = @histogram.sort[@histogram.length/2]
    sum_sq_diff = (weighted_freq.reduce{ |accum,i| accum + (i-avg)**2 })
    stddev = Math.sqrt(sum_sq_diff/(@histogram.length-1))

    { histogram: @histogram, average: avg, median: median, 
      stddev: stddev }.to_json
  end

  # request manual dose be administered
  post '/api/manual_dose' do
    return nil if @@experiment_done
    @@dose = @@experiment_settings[:dosage]
    log_dose dosage_ul: @@dose, requested_manually: true
    puts "Dose requested manually"
  end

  # request name of most recent image captured from the microscope
  get '/api/recent_img' do
    content_type :json
    { path: "/assets/imgs/#{@@recent_img_name}" }.to_json
  end

  # request the current settings from the server
  get '/api/settings' do
    content_type :json

    time_diff = @@end_time - Time.now
    hours = time_diff.div(60*60).floor
    minutes = time_diff.modulo(60*60).div(60).floor

    @@experiment_settings[:hours_left] = hours
    @@experiment_settings[:minutes_left] = minutes

    @@experiment_settings.to_json
  end
end
