require 'sinatra'
require 'sinatra/activerecord'

set :database, 'sqlite3:///db/experiment_logs.sq3'

require './models/ExperimentLog'
