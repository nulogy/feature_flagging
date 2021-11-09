require_relative "lib/feature_flagging/version"

Gem::Specification.new do |spec|
  spec.name          = "feature_flagging"
  spec.version       = FeatureFlagging::VERSION
  spec.authors       = ["Shahriyar Nasir"]
  spec.email         = ["engineering@nulogy.com"]

  spec.summary       = "Thin wrapper around LaunchDarkly for setting up and accessing feature flags."
  spec.description   = "Thin wrapper around LaunchDarkly for setting up and accessing feature flags."
  spec.homepage      = ""

  spec.files         = Dir.glob("{lib}/**/*")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "launchdarkly-server-sdk", "~> 6.2"

  spec.add_development_dependency "listen", "~> 3.7.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
