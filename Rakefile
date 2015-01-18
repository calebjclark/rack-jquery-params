require 'bundler/gem_tasks'
require 'rake/testtask'
require 'fileutils'
include FileUtils

# Default Rake task is compile
#task :default => :compile

########################################################################

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.libs.push "test"
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end
