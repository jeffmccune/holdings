require_relative 'lib/holdings/version'

Gem::Specification.new do |spec|
  spec.name          = "holdings"
  spec.version       = Holdings::VERSION
  spec.authors       = ["Jeff McCune"]
  spec.email         = ["jeff@openinfrastructure.co"]

  spec.summary       = %q{Convert Personal Capital getHoldings JSON to CSV}
  spec.description   = %q{Convert Personal Capital getHoldings JSON to CSV}
  spec.homepage      = "https://github.com/jeffmccune/holdings"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jeffmccune/holdings"
  spec.metadata["changelog_uri"] = "https://github.com/jeffmccune/holdings/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
