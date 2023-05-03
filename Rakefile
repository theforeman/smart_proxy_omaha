require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the Foreman Proxy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

begin
  require 'ci/reporter/rake/test_unit'
rescue LoadError
  # test group not enabled
else
  namespace :jenkins do
    desc nil # No description means it's not listed in rake -T
    task unit: ['ci:setup:testunit', :test]
  end
end
