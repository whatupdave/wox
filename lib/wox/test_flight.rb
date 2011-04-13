module Wox
  class TestFlight < Task
    include Environment
    
    def notes
      environment[:notes].respond_to?(:call) ? environment[:notes].call : environment[:notes]
    end
    
    def lists
      environment[:notify].respond_to?(:join) ? environment[:notify].join(",") : environment[:notify]
    end
    
    def publish
      args = { 
        :file => "@#{environment.ipa_file}",
        :api_token => environment[:api_token],
        :team_token => environment[:team_token],
        :notes => notes
      }
      if environment[:notify]
        args[:notify] = "True"
        args[:distribution_lists] = lists
      end
      
      arg_string = args.map {|k,v| "-F #{k}='#{v}'"}.join(" ")
      
      puts "Uploading ipa to TestFlight"
      log_file = File.join environment[:build_dir], "testflight.log"
      run_command "curl --progress-bar #{arg_string} http://testflightapp.com/api/builds.json", :results => log_file
    end

  end
end