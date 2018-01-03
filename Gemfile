source 'https://rubygems.org'
gemspec

group :development do
  gem 'smart_proxy', :git => 'https://github.com/theforeman/smart-proxy.git', :branch => 'develop'
  gem 'rubocop', '0.38.0' if RUBY_VERSION > '1.8.7'
end

group :test do
  gem 'single_test'
  gem 'test_xml'

  if RUBY_VERSION < '2.1'
    gem 'public_suffix', '< 3'
    gem 'nokogiri', '< 1.7'
  else
    gem 'public_suffix'
    gem 'nokogiri'
  end

  if RUBY_VERSION < '2.2'
    gem 'rack-test', '< 0.8'
  else
    gem 'rack-test'
  end
end

if RUBY_VERSION < '2.2'
  gem 'sinatra', '< 2'
  gem 'rack', '>= 1.1', '< 2.0.0'
else
  gem 'sinatra'
  gem 'rack', '>= 1.1'
end
