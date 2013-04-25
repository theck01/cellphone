require 'sinatra/base'

module Sinatra
  module Logs

    @@logs = []

    def log_array
      @@logs
    end

    # log params to the dose csv file
    def log_dose (params)
      log_hash = {
        timestamp: datestamp,
        dosage_ul: 1,
        administered: false,
        requested_automatically: false,
        requested_manually: false
      }

      log_hash.keys.each{ |k| log_hash[k] = params[k] if params[k] }

      if File.exists?('./logs/doses.csv')
        File.open('./logs/doses.csv','a') do |file|
          file.puts(log_hash.values.to_s[1..-2])
        end
      else
        File.open('./logs/doses.csv','w') do |file|
          file.puts("#" << log_hash.keys.to_s[1..-2])
          file.puts(log_hash.values.to_s[1..-2])
        end
      end

      if log_hash[:administered]
        @@logs << "#{timestamp} - Dose size of #{log_hash[:dosage_ul]}ml administered"
      elsif log_hash[:requested_automatically]
        @@logs << "#{timestamp} - Dose size of #{log_hash[:dosage_ul]}ml dosage requested automatically"
      elsif log_hash[:requested_manually]
        @@logs << "#{timestamp} - Dose size of #{log_hash[:dosage_ul]}ml dosage requested manually"
      end
    end

    # log string to the notes text file
    def log_note (logstr)
      File.open('./logs/notes.txt', 'a') do |file|
        file.puts '' << datestamp << " - " << logstr.to_s
      end
      @@logs << "#{datestamp} - #{logstr}"
    end

    # log the experiment setup
    def log_setup (setup)
      File.open('./logs/setup.txt', 'w') do |file|
        [:name, :title, :description, :expectations].each do |k|
          file.puts "#{k.capitalize}: #{setup[k]}"
        end
      end
    end

    protected

    def datestamp
      Time.now.strftime('%m-%d-%Y %I:%M:%S%p')
    end

    def timestamp
      Time.now.strftime('%I:%M:%S%p')
    end
  end

  helpers Logs
end
