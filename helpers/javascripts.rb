require 'sinatra/base'

module Sinatra
  module Javascripts

    # routes method adds route specific javascript files (without .js extension)
    # to @js
    def scripts (*js)
      @js ||= []
      @js << js
    end

    # view method transforms all javascript filenames global to app 
    # (from settings.javascripts) and local to route (from @js) into
    # valid html 
    def javascripts
      scripts = []
      scripts << settings.javascripts.keys if settings.respond_to?('javascripts')
      scripts << @js if @js
      scripts.flatten.uniq.map do |js|
        "<script src='#{path_to_script js.to_s}'></script>"
      end.join
    end

    protected

    # helper method converts script filenames to paths to scripts
    def path_to_script (script)

      global_scripts = settings.javascripts if settings.respond_to?('javascripts')
      global_scripts ||= {}

      if settings.respond_to?('local_javascripts_path')
        local_path = settings.local_javascripts_path
      end
      local_path ||= '/'
      
      path = global_scripts[script] 
      path ||=  local_path + script + '.js'
    end
  end

  helpers Javascripts
end
