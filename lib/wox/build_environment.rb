require 'plist'

module Wox
  module Environment
    attr_reader :environment
    def initialize environment
      @environment = environment
    end
  end
  
  class BuildEnvironment
    attr_reader :info_plist, :build_dir, :default_sdk
    
    def initialize options
      @options = options
      
      options[:info_plist] ||= 'Resources/Info.plist'
      options[:version] ||= Plist::parse_xml(options[:info_plist])['CFBundleVersion']
      options[:project_name] ||= xcodebuild_list.first.scan(/project\s\"([^\"]+)/i).flatten.first
      options[:full_name] ||= "#{self[:project_name]} #{self[:version]}"
      options[:build_dir] ||= 'build'
      options[:sdk] ||= 'iphoneos'
      options[:configuration] ||= 'Release'
      options[:target] ||= targets.first
      options[:app_file] ||= self[:project_name]
      
      if options[:ipa_name]
        options[:ipa_file] ||= File.join self[:build_dir], 
                                [self[:project_name], self[:version], self[:configuration], self[:ipa_name]].join("-") + ".ipa"
      end
    end
    
    def apply options, &block
      yield BuildEnvironment.new @options.merge(options)
    end
    
    def version
      self[:version]
    end
        
    def sdks
      @sdks ||= `xcodebuild -showsdks`.scan(/-sdk (.*?$)/m).flatten
    end
    
    def configurations
      @configurations ||= begin
        start_line = xcodebuild_list.find_index{ |l| l =~ /configurations/i } + 1
        end_line = xcodebuild_list.find_index{ |l| l =~ /if no/i } - 1
        xcodebuild_list.slice start_line...end_line
      end
    end

    def targets
      @targets ||= begin
        start_line = xcodebuild_list.find_index{ |l| l =~ /targets/i } + 1
        end_line = xcodebuild_list.find_index{ |l| l =~ /configurations/i } - 1
        xcodebuild_list.slice start_line...end_line
      end
    end
    
    def [](name)
      fail "You need to specify :#{name} in Rakefile" unless @options[name]
      @options[name].respond_to?(:call) ? @options[name].call : @options[name]
    end
    
    def has_entry? name
      @options[name]
    end
        
    private
    
      def xcodebuild_list
        @xcodebuild_list ||= `xcodebuild -list`.lines.map{|l| l.strip }.to_a
      end
    
  end
end