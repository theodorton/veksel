# Configure Rails Environment
ENV["RAILS_ENV"] = "development"

def system!(command, options = {})
  system(command, {
    exception: true,
    out: ENV['CI'] ? $stdout : '/dev/null',
    err: ENV['CI'] ? $stderr : '/dev/null',
  }.merge(options))
end

Dir.chdir('test/dummy') do
  # Initialize a new git repository in the dummy app
  system!('rm -rf .git')
  system!('git init --initial-branch=main .')
  system!('git config user.email "you@example.com"')
  system!('git config user.name "Your Name"')
  system!('git add .')
  system!('git commit -q -m "Initial commit"')

  # Make sure the database is setup in main
  system('bin/rails db:setup') || raise("Failed to setup database")
end

ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [File.expand_path("fixtures", __dir__)]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end
