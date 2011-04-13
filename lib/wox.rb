require 'thor'

module Wox
  class Tasks
    def self.install(opts = {})
      resource_file = opts[:resource_file] || 'Resources/Info.plist'
      app_name = opts[:app_name] || File.split(Dir.pwd).last
      version = Plist::parse_xml(resource_file)['CFBundleVersion']
      self.new(app_name, version)
    end
    
    attr_reader :app_name, :version
    
    def initialize(app_name, version)
      @app_name = app_name
      @version = version
    end
    
    def install
      desc "Builds #{app_name}"
      task :build do
        build_app
      end
    end
    
    def build_app
      sh "xcodebuild -target '#{app_name}' -configuration Release > build/build.log"
    end
  end
end
