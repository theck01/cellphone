
# API routes
class AutoExpApp < Sinatra::Base

  # request name of most recent image captured from the microscope
  get '/api/recent_img' do
    content_type :json
    if @@recent_img_name
      { path: "/assets/imgs/#{@@recent_img_name}" }.to_json
    else
      { path: "/assets/imgs/placeholder.jpg" }.to_json
    end
  end

  # request dosage and syringe information as json
  get '/api/dose' do
    content_type :json
    { dose: 1, syringe_size: 10 }.to_json
  end
end

