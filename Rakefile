require 'rake/testtask'

task :default => :test

desc "Run all tests"
Rake::TestTask.new(:test) do |task|
  task.pattern = "test/*/*_test.rb"
end
