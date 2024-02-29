require "test_helper"

class VekselTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Veksel::VERSION
  end

  def git_checkout(branch, &blk)
    system!("git checkout -q -B #{branch}")
    blk.call if block_given?
  ensure
    system!("git checkout -q main") if block_given?
  end

  def setup
    ENV['RAILS_ENV'] = 'development'
    Dir.chdir('test/dummy') do
      git_checkout('main')
      system("git branch -q -D somebranch", { exception: false, err: '/dev/null' })
      system("git branch -q -D some_branch", { exception: false, err: '/dev/null' })
      system!('bin/rails veksel:clean')
    end
  end

  test "integration" do
    Dir.chdir('test/dummy') do
      git_checkout('somebranch') do
        system!('bin/rails veksel:fork')
        current_db = `bin/rails runner "print ApplicationRecord.connection.execute('SELECT current_database();')[0]['current_database']"`.chomp
        assert_equal 'veksel_dummy_development_somebranch', current_db
        assert_equal `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development`, `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development_somebranch`
      end
    end
  end

  test "db:create should be idempotent and not fail on subsequent checkouts" do
    Dir.chdir('test/dummy') do
      git_checkout('somebranch') do
        system!('bin/rails veksel:fork')
      end

      git_checkout('somebranch') do
        system!('bin/rails veksel:fork')
      end
    end
  end

  test "branch names with underscore should work fine" do
    Dir.chdir('test/dummy') do
      git_checkout('some_branch') do
        system!('bin/rails veksel:fork')
        current_db = `bin/rails runner "print ApplicationRecord.connection.execute('SELECT current_database();')[0]['current_database']"`.chomp
        assert_equal 'veksel_dummy_development_some_branch', current_db
        assert_equal `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development`, `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development_some_branch`
      end
    end
  end
end
