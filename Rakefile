require 'rake'

task default: [:test, :rubocop]

task :test do
  ruby 'test/tests.rb'
  ruby 'test/test_mock_rimesync.rb'
end

task :doc do
  system 'rdoc lib/'
end

# rake lint
task :rubocop do
  require 'rubocop/rake_task'
  desc 'Run RuboCop on the current directory'
  # run rubocop recursively through all the files
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['**/*.rb']
    # only show the files with failures
    task.formatters = ['files']
    # don't abort rake on failure
    task.fail_on_error = false
  end
end
