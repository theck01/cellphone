require 'sinatra/base'

module Sinatra
  module ImageCapture

    # capture an image from the microscope
    def get_image (name,path=".")

      # drop final / in path if it exists
      path = path[0..-2] if path[-1] == '/'

      image_name = "#{name}#{DateTime.now.strftime("_%Hh%Mm%Ss_%b-%d-%Y")}.jpg"
      image_path = "#{path}/#{image_name}"

      # run image capture program
      `lib/TWAINCom #{image_path} -fjpg -grayscale -h -o`
      image_path
    end
  end

  helpers ImageCapture
end

