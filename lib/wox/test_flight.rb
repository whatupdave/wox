require 'wox/helpers/number_helper'

module Wox
  class TestFlight < Task
    include Environment
    include NumberHelper
    
    def arg_to_string arg
      arg.respond_to?(:join) ? arg.join(",") : arg
    end
    
    def publish
      ipa_file = environment.ipa_file
      
      args = { 
        :file => "@#{ipa_file}",
        :api_token => environment[:api_token],
        :team_token => environment[:team_token],
        :notes => environment[:notes]
      }
      
      if environment.has_entry? :distribution_lists
        args[:distribution_lists] = arg_to_string environment[:distribution_lists]
      end
      
      if environment.has_entry? :notify
        args[:notify] = environment[:notify]
      end
      
      arg_string = args.map {|k,v| "-F #{k}='#{v}'"}.join(" ")
      
      file_size_in_megabytes = bytes_to_human_size File.size?(ipa_file)
      
      puts "Publishing to TestFlight"
      puts "File: #{ipa_file} (#{file_size_in_megabytes})"
      puts "Accessible To: #{args[:distribution_lists]}" if environment.has_entry? :distribution_lists
      puts "Notifying team members" if environment.has_entry? :notify
      
      log_file = File.join environment[:build_dir], "testflight.log"
      run_command "curl --progress-bar #{arg_string} http://testflightapp.com/api/builds.json", :results => log_file
    end

  end
end