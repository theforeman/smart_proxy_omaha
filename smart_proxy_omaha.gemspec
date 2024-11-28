# frozen_string_literal: true

require File.expand_path('lib/smart_proxy_omaha/version', __dir__)

Gem::Specification.new do |s|
  s.name = 'smart_proxy_omaha'
  s.version = Proxy::Omaha::VERSION

  s.summary = 'Omaha protocol support for smart-proxy'
  s.description = 'This plug-in adds support for the Omaha Procotol to Foreman\'s Smart Proxy.'
  s.authors = ['Timo Goebel']
  s.email = 'mail@timogoebel.name'
  s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.files = `git ls-files`.split("\n") - ['.gitignore']
  s.executables = ['smart-proxy-omaha-sync']
  s.homepage = 'https://github.com/theforeman/smart_proxy_omaha'
  s.license = 'GPL-3.0-only'

  s.add_dependency('nokogiri', '>= 1.5.11')

  s.required_ruby_version = '>= 2.7', '< 4'
end
