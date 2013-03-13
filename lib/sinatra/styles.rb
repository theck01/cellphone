require 'sinatra/base'

module Sinatra
  module Styles

    # routes method adds route specific css stylesheet filenames to @styles
    def styles (*stylesheets)
      @styles ||= []
      @styles << stylesheets.map{ |s| s.to_s }
    end

    # view method transforms all css filenames global to app (from settings.css)
    # and local to route (@js) into valid html
    def stylesheets
      sheets = []
      sheets << settings.stylesheets.keys if settings.respond_to?('stylesheets')
      sheets << @styles if @styles
      sheets.flatten.uniq.map do |css|
        "<link href='#{path_to_styles css }' rel='stylesheet' type='text/css'>"
      end.join
    end

    protected

    def path_to_styles (stylesheet)
      
      global_sheets = settings.stylesheets if settings.respond_to?('stylesheets')
      global_sheets ||= {}

      if settings.respond_to?('local_stylesheet_path')
        local_path = settings.local_stylesheet_path
      end
      local_path ||= '/'
      
      path = global_sheets[stylesheet] 
      path ||=  local_path + stylesheet + '.css'
    end
  end
  helpers Styles
end
