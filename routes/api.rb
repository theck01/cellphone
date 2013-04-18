class AutoExpApp < Sinatra::Base

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json

    puts 'Dose administered' if @@dose != 0
    dose = @@dose
    @@dose = 0
    { dose: dose, syringe_size: @@experiment_settings[:syringe] }.to_json
  end

  # request the histogram of the last saved image
  get '/api/histogram' do
    content_type :json

    path = "./public/assets/histograms"
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
    @@dose = @@experiment_settings[:dosage]
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
    @@experiment_settings.to_json
  end
end
