class AutoExpApp < Sinatra::Base

  # start experiment, if one is not already running
  get '/experiment/begin' do
    unless @@img_thread

      #new image capture worker process
      @@img_thread = Thread.new do
        while true do
          recent_img_name = get_image 'test', './public/assets/imgs'
          @@recent_img_name = File.basename recent_img_name
        end
      end

      puts "started img thread, has value: #{@@img_thread}"
    end

    redirect 'experiment/show'
  end

  # end the experiment, if one is running
  get '/experiment/end' do
    if @@img_thread
      @@img_thread = @@img_thread.terminate
      puts "killed thread, has value: #{@@img_thread}"
    end

    redirect '/'
  end

  # observe the experiment currently running
  get '/experiment/show' do
    scripts :experiment
    @page = 'experiment/show'
    haml :layout
  end
end
