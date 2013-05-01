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

  # request the results zip file
  get  '/api/download_results' do
    filename = "#{@@experiment_setup[:file_prefix]}.zip"
    send_file "./public/results/#{filename}", filename: filename, type: 'application/zip', disposition: :attachment
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

  # request logs as html to include in show page
  get '/api/logs' do
    log_array.reverse.join("\n\n")
  end

  # request manual dose be administered
  post '/api/manual_dose' do
    return nil if @@experiment_done
    @@dose = @@experiment_settings[:dosage]
    log_dose dosage_ul: @@dose, requested_manually: true
    puts "Dose requested manually"
  end

  # request that a note taken by the experimenter be saved
  post '/api/note' do
    log_note params[:note]
  end

  # pause the current experiment
  post '/api/pause' do
    @@experiment_paused = true
  end

  # request name of most recent image captured from the microscope
  get '/api/recent_img' do
    content_type :json
    { path: "/assets/imgs/#{@@recent_img_name}" }.to_json
  end

  # resume the current experiment
  post '/api/resume' do
    @@experiment_paused = false
    @@img_thread.run if @@img_thread
  end

  # request the current settings from the server
  get '/api/settings' do
    content_type :json
    @@experiment_settings.to_json
  end

  # request status of the experiment
  get '/api/state' do
    content_type :json
    
    @state = {}

    if @@experiment_done || !@@end_time
      time_diff = 0
    else
      time_diff = @@end_time - Time.now
    end

    @state[:hours_left] = time_diff.div(60*60).floor
    @state[:minutes_left] = time_diff.modulo(60*60).div(60).floor


    @state[:state] = if @@experiment_done
      "Finished"
    elsif @@experiment_paused
      "Paused"
    elsif @@dose != 0
      "Dose Pending"
    else
      "Running"
    end

    @state.to_json
  end
end
