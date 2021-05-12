# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ten34/version'

Gem::Specification.new do |spec|
  spec.name          = 'ten34'
  spec.version       = Ten34::VERSION
  spec.authors       = ['Tony Burns']
  spec.email         = ['tony@tonyburns.net']

  spec.summary       = 'A globally-distributed key-value store built on top of cloud DNS services'
  spec.description   = 'A globally-distributed key-value store built on top of cloud DNS services'
  spec.homepage      = 'https://ten34.dev'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/craftyphotons/ten34'
  spec.metadata['changelog_uri'] = 'https://github.com/craftyphotons/ten34/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'aws-sdk', '~> 3.0'
  spec.add_dependency 'google-cloud-dns'
  spec.add_dependency 'google-cloud-kms'
  spec.add_dependency 'retriable'
  spec.add_dependency 'thor'
  spec.add_dependency 'tty-logger'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
