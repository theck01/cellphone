
require 'sinatra'
require 'sinatra/activerecord'

set :database, 'sqlite3:///db/experiment_logs.sq3'

class ExperimentLog < ActiveRecord::Base
end
