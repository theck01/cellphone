require 'restclient'

class AutoExpApp < Sinatra::Base

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json
    { dose: 1, syringe_size: 10 }.to_json
  end

  # request the histogram of the last saved image
  get '/api/histogram' do
    content_type :json
    begin
      response = RestClient.get "http://#{settings.histogrammer_ip}:3000/api/histogram/#{@@recent_img_name}"
      File.open("./public/assets/histograms/histogram_of_#{@@recent_img_name}", "w") do |file|
        file.puts response.body
      end
      response.body
    rescue
      File.open("./public/assets/histograms/.histogram_of_#{@@recent_img_name}") do |file|
        prev_hist = file.gets
      end
      prev_hist
    end
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
