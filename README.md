# The Wizard of Xcode

wox is a ruby gem that adds useful rake tasks in order to have happier iOS devs.

## Install

First set up bundler in your xcode app directory (unless you already have!)

    $ cd ~/code/angry_turds
    $ gem install bundler
    $ bundle init

Then edit your Gemfile to look something like this:

    # Gemfile
    source :rubygems
    gem "wox"
    
Then run the bundle command:

    $ bundle

Now, create a Rakefile (unless you already have one!):
    
    # Rakefile
    include Rake::DSL
    require 'bundler'
    Bundler.require

    Wox::Tasks.create :info_plist => 'Resources/Info.plist' do
      build :debug, :configuration => 'Debug'
    end
    
Now run rake -T to show you the available rake commands and you should see something like this:

    $ rake -T
    rake build:debug          # Build angry_turds 0.1 with Debug configuration
    rake info:configurations  # List available configurations
    rake info:sdks            # List available sdks
    $ rake build:debug
    Building angry_turds 0.3 configuration:Debug
    Success. Results in build/build-Debug.log

If you get an error you might need to check the path of the info plist file. We use that to get the version number of the app.
    
## Moar stuff!

Ok so there's a few more things you can do, like creating ipa files and publishing to TestFlight. That looks like this:

    # Rakefile
    include Rake::DSL
    require 'bundler'
    Bundler.require

    Wox::Tasks.create :info_plist => 'Resources/Info.plist', :sdk => 'iphoneos', :configuration => 'Release' do
      build :debug, :configuration => 'Debug'

      build :release, :developer_certificate => 'iPhone Developer: Dangerous Dave (9GZ84DL0DZ)' do
        ipa :app_store, :provisioning_profile => 'App Store'
        ipa :adhoc, :provisioning_profile => 'Team Provisioning Profile' do
          testflight :publish, :api_token => 'nphsZ6nVXMl0brDEsevLY0wRfU6iP0NLaQH3nqoh8jG',
                               :team_token => 'Qfom2HnGGJnXrUVnOKAxKAmpNO3wdQ9panhtqcA',
                               :notes => proc { File.read("CHANGELOG") },
                               :distribution_lists => %w[Internal QA],
                               :notify => true

        end
      end
    end
    
There's a few things to notice here. Some tasks need to be nested inside other tasks. This allows them to share environment variables. For example :configuration => 'Release' is on the outer most scope at the top there. That sets the default for all the tasks inside. Any task can override the default like the first build :debug task does. The build :release task sets a developer certificate here which is then shared by the two inner ipa tasks.
    
rake -T again:

    $ rake -T
    rake build:debug          # Build angry_turds 0.1 with Debug configuration
    rake build:release        # Build angry_turds 0.1 with Release configuration
    rake info:configurations  # List available configurations
    rake info:sdks            # List available sdks
    rake ipa:adhoc            # Creates build/angry_turds-0.1-release-adhoc.ipa
    rake ipa:app_store        # Creates build/angry_turds-0.1-release-app_store.ipa
    rake testflight:publish   # Publishes build/angry_turds-0.1-release-adhoc.ipa to testflight

You'll need to sign up to [TestFlight](http://testflightapp.com) to get your API key and team token which you can plug in here.

Also check your development certificate and provisioning profile from inside Xcode.

## Available options

The following options can be set at any level and will be inherited by child tasks.

 * :info_plist        Default: 'Resources/Info.plist'
 * :version           Default: 'CFBundleVersion' from info plist file
 * :target            Default: first target in xcode
 * :sdk               Default: 'iphoneos'
 * :build_dir         Default: 'build'
 * :configuration     Default: 'Release'
 * :project_name      Default: project name from xcode
 * :app_file          Default: project_name
 * :ipa_name          Default: 'project_name-version-configuration-ipa_name'

## Wrapping up

This is very much a WIP! So please log any bugs or feedback you might have and feel free to fork and go nuts!

    

