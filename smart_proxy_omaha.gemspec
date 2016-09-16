require File.expand_path('../lib/smart_proxy_omaha/version', __FILE__)

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
  s.homepage = 'http://github.com/theforeman/smart_proxy_omaha'
  s.license = 'GPLv3'

  s.add_dependency('nokogiri')
  s.add_dependency('json')

  s.add_development_dependency('rake')
  s.add_development_dependency('mocha')
  s.add_development_dependency('test-unit')
end
