class AutoExpApp < Sinatra::Base

  # render the setup page
  get '/experiment/setup' do
    scripts :experiment_setup
    @page = 'experiment/setup'
    haml :layout
  end

  post '/experiment/form_test' do
    params.to_s
  end

  # start experiment, if one is not already running
  post '/experiment/begin' do
    unless @@img_thread

      #new image capture worker process
      @@img_thread = Thread.new do
        while true do
          recent_img_name = get_image 'test', './public/assets/imgs'
          @@recent_img_name = File.basename recent_img_name
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

  # observe the experiment currently running
  get '/experiment/show' do
    scripts :experiment_show
    @page = 'experiment/show'
    haml :layout
  end
end
