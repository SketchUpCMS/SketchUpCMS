require "rake/testtask"

##____________________________________________________________________________||
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/Test*.rb']
  t.verbose = true
end

task :default => :test

##____________________________________________________________________________||
