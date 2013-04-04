class AutoExpApp < Sinatra::Base

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json
    { dose: 1, syringe_size: 10 }.to_json
  end

  # request the histogram of the last saved image
  get '/api/histogram' do
    redirect "http://#{settings.histogrammer_ip}:3000/api/histogram/#{@@recent_img_name}"
  end

  # request name of most recent image captured from the microscope
  get '/api/recent_img' do
    content_type :json
    { path: "/assets/imgs/#{@@recent_img_name}" }.to_json
  end
end
