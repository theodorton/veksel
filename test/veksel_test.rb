require "test_helper"

module TestHelpers
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
end

class VekselTest < ActiveSupport::TestCase
  include TestHelpers

  test "it has a version number" do
    assert Veksel::VERSION
  end

  class IntegrationTests < ActiveSupport::TestCase
    include TestHelpers

    def run_fork_test
      system!('bundle exec veksel fork')
      current_db = `bin/rails runner "print ApplicationRecord.connection.execute('SELECT current_database();')[0]['current_database']"`.chomp
      assert_equal 'veksel_dummy_development_somebranch', current_db
      assert_equal `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development`, `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development_somebranch`
    end

    test "veksel fork should work with database.yml without ERB" do
      Dir.chdir('test/dummy') do
        git_checkout('somebranch') do
          run_fork_test
        end
      end
    end

    test "veksel fork should work with database.yml with ERB" do
      swap_db_config('database.erb.yml') do
        Dir.chdir('test/dummy') do
          git_checkout('somebranch') do
            run_fork_test
          end
        end
      end
    end

    test "veksel fork should work when using primary: db config" do
      swap_db_config('database.primary.yml') do
        Dir.chdir('test/dummy') do
          git_checkout('somebranch') do
            run_fork_test
          end
        end
      end
    end
  end

  test "veksel fork should warn on unsupported database adapters" do
    swap_db_config('database.sqlite.yml') do
      Dir.chdir('test/dummy') do
        begin
          system!('bin/rails db:setup')
          system!('bin/rails veksel:clean')

          git_checkout('somebranch') do
            Tempfile.open do |buffer|
              system!('bundle exec veksel fork', exception: false, err: buffer.path.to_s)
              buffer.rewind
              output = buffer.read
              assert_match /Veksel does not yet support sqlite3 - fork skipped/, output
            end
          end
        end
      end
    end
  end

  test "performance" do
    def measure_in_ms(&blk)
      t0 = (Time.now.to_f * 1000).to_i
      yield
      t1 = (Time.now.to_f * 1000).to_i
      return t1 - t0
    end

    Dir.chdir('test/dummy') do
      git_checkout('somebranch') do
        Tempfile.open do |buffer|
          command_duration = measure_in_ms do
            system!('bundle exec veksel fork', out: buffer.path.to_s)
          end
          buffer.rewind
          output = buffer.read
          fork_duration = output.match(/Forked database in (\d+)ms/)[1].to_i
          allowed_overhead_ms = 200
          assert_operator command_duration, :<, fork_duration + allowed_overhead_ms
        end
      end
    end
  end unless ENV['CI']

  test "db:create should be idempotent and not fail on subsequent checkouts" do
    Dir.chdir('test/dummy') do
      git_checkout('somebranch') do
        system!('bundle exec veksel fork')
      end

      git_checkout('somebranch') do
        system!('bundle exec veksel fork')
      end
    end
  end

  test "branch names with underscore should work fine" do
    Dir.chdir('test/dummy') do
      git_checkout('some_branch') do
        system!('bundle exec veksel fork')
        current_db = `bin/rails runner "print ApplicationRecord.connection.execute('SELECT current_database();')[0]['current_database']"`.chomp
        assert_equal 'veksel_dummy_development_some_branch', current_db
        assert_equal `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development`, `PGPASSWORD=foobar pg_dump -s -h localhost -p 5555 -U veksel veksel_dummy_development_some_branch`
      end
    end
  end

  test "listing out databases" do
    Dir.chdir('test/dummy') do
      git_checkout('somebranch') do
        system!('bundle exec veksel fork')
        output = `bin/rails veksel:list`.lines.filter(&:present?).map(&:squish).map { |s| s.split(' ') }.to_enum
        assert_equal 'Databases created by Veksel:', output.next.join(" ")
        assert_equal %w[Branch Database Active], output.next
        assert_equal %w[somebranch veksel_dummy_development_somebranch Yes], output.next
      end
    end
  end
end
