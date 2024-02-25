require "test_helper"

class VekselTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Veksel::VERSION
  end

  def git_checkout(branch, &blk)
    system!("git checkout -B #{branch}")
    blk.call
  ensure
    system!("git checkout main")
  end

  def system!(command, options = {})
    system(command, {
      exception: true,
      out: '/dev/null',
      err: '/dev/null',
    }.merge(options))
  end

  def setup
    ENV['RAILS_ENV'] = 'development'
    system!("git checkout main")
    system!("git branch -D somebranch", { exception: false })
    system!("git branch -D some_branch", { exception: false })
    Dir.chdir('test/dummy') do
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
