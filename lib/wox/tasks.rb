require 'thor'

module Wox
  class Tasks
    def self.create(opts = {}, &block)
      self.new(opts).instance_eval &block
    end
    
    attr_reader :info_plist, :build_dir, :default_sdk
    
    def initialize(opts)
      @info_plist = opts[:info_plist] || 'Resources/Info.plist'
      @build_dir = opts[:build_dir] || 'build'
      @default_sdk = opts[:sdk] || 'iphoneos'
    end
        
    def full_name
      "#{project_name} #{version}"
    end
    
    def xcodebuild_list
      @xcodebuild_list ||= `xcodebuild -list`.lines.map{|l| l.strip }.to_a
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
    
    def project_name
      @project_name ||= xcodebuild_list.first.scan(/project\s\"([^\"]+)/i).flatten.first
    end
    
    def version
      @version ||= Plist::parse_xml(info_plist)['CFBundleVersion']
    end
    
    def task_name name
      name.gsub(' ','_').downcase
    end
    
    def build *configurations
      namespace :build do
        configurations.each do |c|
          desc "Build #{full_name} with #{c} configuration"
          task task_name(c) { build_app c }
        end
      end
    end
    
    def ipa name, opts
      namespace :ipa do
        configuration = opts[:configuration]
        fail "You need to specify ipa :configuration" unless configuration
        
        ipa_file = File.join build_dir, "#{project_name}-#{version}-#{task_name(configuration)}-#{name}.ipa"
        desc "Creates #{ipa_file}"
        task(name) { build_ipa ipa_file, opts }
      end
    end
        
    def build_app configuration
      puts "Building #{full_name} configuration:#{configuration}"
      
      log_file = File.join build_dir, "build-#{configuration}.log"
      if run_command "xcodebuild -target '#{project_name}' -configuration #{configuration}", log_file
        puts "Build successful. Results in #{log_file}"
      else
        system "cat #{log_file}"
      end
      
    end
    
    
    def build_ipa ipa_file, opts
      configuration = opts[:configuration]

      sdk = opts[:sdk] || default_sdk
      
      [:provisioning_profile, :developer_certificate].each do |option|
        fail "You need to specify ipa #{option}" unless opts[option]
      end

      app_file = File.join build_dir, "#{configuration}-#{sdk}", "#{project_name}.app"
      fail "Couldn't find #{app_file}" unless File.exists? app_file
      
      provisioning_profile_file = find_matching_mobile_provision opts[:provisioning_profile]
      fail "Unable to find matching provisioning profile for '#{opts[:provisioning_profile]}'" if provisioning_profile_file.empty?
            
      build_app configuration
      puts "Creating #{ipa_file}"
      log_file = File.join build_dir, "ipa.log"
      if run_command "xcrun -sdk #{sdk} PackageApplication -v '#{app_file}' -o '#{File.expand_path ipa_file}' --sign '#{opts[:developer_certificate]}' --embed '#{provisioning_profile_file}'", log_file
        puts "IPA creation successful. Results in #{log_file}"
      else
        system "cat #{log_file}"
      end
    end
    
    def run_command text, output_file
      result = `#{text}`
      
      File.open(output_file, "w") {|f| f.write result }
      
      $?.to_i == 0
    end
    
    def find_matching_mobile_provision match_text
      `grep -rl '#{match_text}' '#{ENV['HOME']}/Library/MobileDevice/Provisioning\ Profiles/'`.strip
    end
    
    
  end
end