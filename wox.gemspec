# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wox/version"

Gem::Specification.new do |s|
  s.name        = "wox"
  s.version     = Wox::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dave Newman"]
  s.email       = ["dave@snappyco.de"]
  s.homepage    = ""
  s.summary     = %q{The Wizard of Xcode}
  s.description = %q{Wox is a collection of build tasks that helps you build and publish iOS appicatinos}

  s.rubyforge_project = "wox"

  s.add_dependency "thor"
  s.add_dependency "plist"
  
  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
