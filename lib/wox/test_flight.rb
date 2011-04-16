require 'wox/helpers/number_helper'

module Wox
  class TestFlight < Task
    include Environment
    include NumberHelper
    
    def notes
      environment[:notes].respond_to?(:call) ? environment[:notes].call : environment[:notes]
    end
    
    def lists
      environment[:notify].respond_to?(:join) ? environment[:notify].join(",") : environment[:notify]
    end
    
    def publish
      ipa_file = environment.ipa_file
      
      args = { 
        :file => "@#{ipa_file}",
        :api_token => environment[:api_token],
        :team_token => environment[:team_token],
        :notes => notes
      }
      if environment.has_entry? :notify
        args[:notify] = "True"
        args[:distribution_lists] = lists
      end
      
      arg_string = args.map {|k,v| "-F #{k}='#{v}'"}.join(" ")
      
      file_size_in_megabytes = bytes_to_human_size File.size?(ipa_file)
      
      puts "Uploading #{ipa_file} (#{file_size_in_megabytes}) to TestFlight"
      log_file = File.join environment[:build_dir], "testflight.log"
      run_command "curl --progress-bar #{arg_string} http://testflightapp.com/api/builds.json", :results => log_file
    end

  end
end