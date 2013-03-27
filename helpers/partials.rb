require 'sinatra/base'

module Sinatra
  module Partials
    def partial (page=nil, variables={})
      haml(page.to_sym, { layout: false }, variables) if page
    end
  end

  helpers Partials
end
