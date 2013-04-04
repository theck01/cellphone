require 'sinatra/base'
require 'sinatra/config_file'
require 'json'
require 'RMagick'
include Magick

# application that exists purely to convert images to histograms. Separated
# from main application because RMagick gem does not interact well with
# threads
class HistogrammerApp < Sinatra::Base

  # MAIN ROUTE

  # returns the histogram of the given image as JSON. Expects images to
  # be found in the ./public/assets/imgs directory
  get '/api/histogram/:img_name' do 
    image_path = "./public/assets/imgs/#{params[:img_name]}"

    # load image
    pixels = ImageList.new(image_path).export_pixels

    # bin image intensities, reducing 16 bit image to 8 bit image
    histogram = Array.new(256,0)
    pixels.each{ |i| histogram[i/256] += 1 }

    histogram.map{ |i| i.to_f/pixels.length }.to_json
  end
end
