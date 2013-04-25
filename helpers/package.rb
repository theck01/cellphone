require 'sinatra/base'
require 'zipruby'

module Sinatra
  module Package

    def package_results (zipname)
      generate_zipfile zipname
      cleanup
    end

    protected

    # generate a zipfile of all results
    def generate_zipfile (filename)
      Zip::Archive.open("results/#{filename}.zip", Zip::CREATE) do |ar|
        Dir.glob('logs/histograms/*').each do |file|
          dest = File.join('histograms',File.basename(file));
          if !File.directory?(file)
            ar.add_file(dest,file)
          end
        end
        Dir.glob('public/assets/imgs/*').each do |file|
          dest = File.join('imgs',File.basename(file));
          if !File.directory?(file)
            ar.add_file(dest,file)
          end
        end
        Dir.glob('logs/*').each do |file|
          if !File.directory?(file)
            ar.add_file(file,file)
          end
        end
      end
    end

    # empty results directories of results
    def cleanup
      clear_directory 'public/assets/imgs'
      clear_directory 'logs/histograms'
      clear_directory 'logs'
    end

    # empty a single directory of files
    def clear_directory (dirname)
      Dir.foreach(dirname) do |file|
        path = File.join(dirname,file)
        File.delete(path) if !File.directory?(path) && file[0] != '.'
      end
    end
  end

  helpers Package
end
