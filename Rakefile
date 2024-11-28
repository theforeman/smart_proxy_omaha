require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Default: run RuboCop and tests.'
task :default => %i[rubocop test]

desc 'Test the Foreman Proxy plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << '.'
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end
