# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "build_comms/version"

Gem::Specification.new do |s|
  s.name        = "BuildComms"
  s.version     = BuildComms::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Lunny"]
  s.email       = ["alunny@gmail.com"]
  s.summary     = %q{communications for PhoneGap Build}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "aws-sdk", "~>2.0"
  s.add_dependency "json"
  s.add_dependency "slack-notifier"

  s.add_development_dependency "rspec"
end
