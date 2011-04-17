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
      options[:info_plist] ||= 'Resources/Info.plist'
      options[:version] ||= Plist::parse_xml(options[:info_plist])['CFBundleVersion']
      options[:project_name] ||= xcodebuild_list.first.scan(/project\s\"([^\"]+)/i).flatten.first
      options[:build_dir] ||= 'build'
      options[:sdk] ||= 'iphoneos'
      options[:configuration] ||= 'Release'
      options[:target] ||= targets.first
      @options = options
    end
    
    def apply options, &block
      yield BuildEnvironment.new @options.merge(options)
    end
    
    def project_name
      self[:project_name] 
    end
        
    def version
      self[:version]
    end
    
    def full_name
      "#{project_name} #{version}"
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
        
    def configuration_sym
      self[:configuration].gsub(' ', '_').downcase
    end
    
    def ipa_file
      File.join self[:build_dir], "#{project_name}-#{version}-#{configuration_sym}-#{self[:ipa_name]}.ipa"
    end
    
    private
    
      def xcodebuild_list
        @xcodebuild_list ||= `xcodebuild -list`.lines.map{|l| l.strip }.to_a
      end
    
  end
end