require 'sinatra/base'

module Sinatra
  module ImageCapture
    def get_image (name="image",path="")
      image_name = "#{name}#{Date.to_s}.jpg"
      image_path = "#{IMAGE_PATH}/#{image_name}"
      `lib/TWAINCom #{image_path} -fjpg -grayscale -h -o`
      image_path
    end
  end

  helpers ImageCapture
end

