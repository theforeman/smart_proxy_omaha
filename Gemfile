# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

group :rubocop do
  gem 'rubocop', '~> 1.28.0'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
end

group :test do
  gem 'ci_reporter_test_unit'
  gem 'mocha'
  gem 'public_suffix'
  gem 'rack-test'
  gem 'rake'
  gem 'smart_proxy', git: 'https://github.com/theforeman/smart-proxy.git', branch: ENV.fetch('SMART_PROXY_BRANCH', 'develop')
  gem 'test-unit'
  gem 'test_xml'
  gem 'webmock'
end
