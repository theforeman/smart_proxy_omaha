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

  if RUBY_VERSION < '1.9'
    s.add_dependency('nokogiri', '<= 1.5.11')
  else
    s.add_dependency('nokogiri', '>= 1.5.10')
  end
  s.add_dependency('json')

  s.add_development_dependency('test-unit', '~> 2')
  s.add_development_dependency('mocha', '~> 1')
  s.add_development_dependency('webmock', '~> 1')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('rake', '~> 10')
end
