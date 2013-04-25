require './helpers/partials'
AutoExpApp.helpers Sinatra::Partials

require './helpers/styles'
AutoExpApp.helpers Sinatra::Styles

require './helpers/javascripts'
AutoExpApp.helpers Sinatra::Javascripts

require './helpers/imagecapture'
AutoExpApp.helpers Sinatra::ImageCapture

require './helpers/logs'
AutoExpApp.helpers Sinatra::Logs

require './helpers/package'
AutoExpApp.helpers Sinatra::Package
