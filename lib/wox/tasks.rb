require 'thor'

module Wox
  module TasksScope
    attr_reader :environment, :parent_task
    def initialize environment, parent_task = nil
      @environment = environment
      @parent_task = parent_task
    end
  end
  
  class Tasks
    def self.create options = {}, &block
      tasks = self.new(BuildEnvironment.new(options))
      tasks.default_tasks
      tasks.instance_eval &block if block_given?
    end

    include TasksScope
    
    def default_tasks
      namespace :info do
        desc "List available sdks"
        task :sdks do
          puts environment.sdks.join("\n")
        end
      
        desc "List available configurations"
        task :configurations do
          puts environment.configurations.join("\n")
        end
      end
    end
    
    def build name, options, &block
      environment.apply options do |e|
        t = nil
        namespace :build do
          desc "Build #{e.full_name} with #{e[:configuration]} configuration"
          t = task(name) { Builder.new(e).build }
        end
        tasks = BuildTasks.new(e, t)
        tasks.instance_eval &block if block_given?
      end
    end
  end
  
  class BuildTasks
    include TasksScope
    
    def ipa name, options, &block
      environment.apply options.merge({:ipa_name => name}) do |e|
        t = nil
        namespace :ipa do
          desc "Creates #{e.ipa_file}"
          t = task(name => parent_task) { Packager.new(e).package }
        end
        
        tasks = IpaTasks.new(e, t)
        tasks.instance_eval &block if block_given?
      end
    end
  end
  
  class IpaTasks
    include TasksScope
    
    def testflight name, options
      environment.apply options do |e|
        namespace :testflight do
          desc "Publishes #{e.ipa_file} to testflight"
          task(name => parent_task) { TestFlight.new(e).publish }
        end
      end
    end
  end  
end