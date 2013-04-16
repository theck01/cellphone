class AutoExpApp < Sinatra::Base

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json
    { dose: @@dose, syringe_size: @@syringe_size }.to_json
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
    avg = @histogram.reduce(:+)/@histogram.length
    median = @histogram.sort[@histogram.length/2]
    sum_sq_diff = (@histogram.reduce{ |accum,i| accum + (i-avg)**2 })
    stddev = Math.sqrt(sum_sq_diff/(@histogram.length-1))

    { histogram: @histogram, average: avg*256, median: median, 
      stddev: stddev }.to_json
  end

  # request name of most recent image captured from the microscope
  get '/api/recent_img' do
    content_type :json
    { path: "/assets/imgs/#{@@recent_img_name}" }.to_json
  end
end
