require 'wox/helpers/number_helper'

module Wox
  class TestFlight < Task
    include Environment
    include NumberHelper
    
    def arg_to_string arg
      arg.respond_to?(:join) ? arg.join(",") : arg
    end

    def api_args
      args = { 
        :file => "@#{environment[:ipa_file]}",
        :api_token => environment[:api_token],
        :team_token => environment[:team_token],
        :notes => environment[:notes]
      }
      
      args[:distribution_lists] = environment[:distribution_lists].join(",") if environment.has_entry? :distribution_lists 
      args[:notify] = environment[:notify] if environment.has_entry? :notify
      args
    end
    
    def curl_arg_string
      api_args.map {|k,v| "-F #{k}='#{v}'"}.join(" ")
    end
    
    def publish
      ipa_file = environment[:ipa_file]
      
      puts "Publishing to TestFlight"
      puts "File: #{ipa_file} (#{bytes_to_human_size File.size?(ipa_file)})"
      puts "Accessible To: #{environment[:distribution_lists].join(", ")}" if environment.has_entry? :distribution_lists
      puts "After publish will notify team members" if environment.has_entry? :notify
      
      log_file = File.join environment[:build_dir], "testflight.log"
      run_command "curl --progress-bar #{curl_arg_string} http://testflightapp.com/api/builds.json", :results => log_file
    end

  end
end