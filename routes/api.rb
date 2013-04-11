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
    url = "http://#{settings.histogrammer_ip}:3000/api/histogram"

    # try to request a new histogram
=begin
    begin
      response = RestClient.get "#{url}/#{@@recent_img_name}"
      @histogram = JSON.parse(response.body)['histogram']

      # save histogram to file
      histfile = "histogram_of_#{File.basename(@@recent_img_name, '.jpg')}"
      File.open("#{path}/#{histfile}.csv", "w") do |file|
        file.puts JSON.parse(response.body)['histogram']
      end
    # if histogrammar resource not available load placeholder
    rescue RestClient::ResourceNotFound
=end
      File.open("#{path}/.histogram_of_placeholder.csv") do |file|
        @histogram = JSON.parse(file.gets)
      end
    #end

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

  put '/api/set_threshold' do
    if params[:threshold].to_i.between?(0,255)
      @@threshold = params[:threshold]
    else
      halt(400)
    end
  end
end
