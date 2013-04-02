require 'sinatra/base'
require 'RMagick'
require 'rvg/rvg'
include Magick

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

    # generate a histogram from an image
    def get_histogram (name, path='.')

      # drop final / in path if it exists
      path = path[0..-2] if path[-1] == '/'

      image_path = "#{path}/#{name}"

      # load image
      pixels = ImageList.new(image_path).export_pixels

      # bin image intensities, reducing 16bit image to 8bit values
      histogram = Array.new(256,0)
      pixels.each{ |i| histogram[i/256] += 1 }

      # normalize pixel intensities
      histogram.map{ |i| i.to_f/pixels.length }
    end
  end

  helpers ImageCapture
end

