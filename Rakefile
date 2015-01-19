require 'bundler/gem_tasks'
require 'rake/testtask'
require 'fileutils'
include FileUtils

task :run_test do
  Rake::Task['test'].execute
  puts '---------------------------------------------------------------------'
  puts 'TESTS PASSED... READY TO BUILD...'
  puts '---------------------------------------------------------------------'
end
task :build => :run_test
task :default => :build

########################################################################

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.libs.push 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end
