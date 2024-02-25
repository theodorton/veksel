namespace :veksel do
  task :precreate do
    ActiveSupport::Notifications.subscribe "veksel.fork" do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      puts "Forked database in #{event.duration.to_i}ms"
      File.open("log/veksel.log", "a") do |f|
        f.puts("Forked database in #{event.duration.to_i}ms")
        f.puts("  Source: #{event.payload[:source]}")
        f.puts("  Target: #{event.payload[:target]}")
      end
    end
  end

  desc "Fork the database from the main branch"
  task fork: ['db:create', 'veksel:precreate'] do
    next if Veksel.skip_fork?
    require 'veksel/commands/fork'

    db = ActiveRecord::Base.configurations.find_db_config('development')
    Veksel::Commands::Fork.new(db).perform
  end

  desc "List forked databases"
  task list: 'db:load_config' do
    require 'veksel/commands/clean'

    db = ActiveRecord::Base.configurations.find_db_config('development')
    command = Veksel::Commands::Clean.new(db)
    databases = command.all_databases
    active_branches = command.active_branches

    if databases.empty?
      puts "No databases created by Veksel"
      next
    end

    hash = {}
    databases.each do |database|
      branch = database.sub(command.prefix, '')
      hash[branch] = database
    end

    longest_branch_name = hash.keys.max_by(&:length).length
    longest_database_name = hash.values.max_by(&:length).length
    puts "Databases created by Veksel:"
    puts ""
    puts "#{'Branch'.ljust(longest_branch_name)}   #{'Database'.ljust(longest_database_name)}   Active"
    inactive_count = 0
    hash.each do |branch, database|
      # Print a formatted string padded to fit the longest branch name
      active = active_branches.include?(branch) ? 'Yes' : 'No'
      inactive_count += 1 if active == 'No'
      puts "#{branch.ljust(longest_branch_name)}   #{database.ljust(longest_database_name)}   #{active}"
    end

    if inactive_count > 0
      puts ""
      puts "Clean inactive databases with bin/rails veksel:clean"
    end
  end

  desc "Delete forked databases"
  task clean: 'db:load_config' do
    require 'veksel/commands/clean'

    db = ActiveRecord::Base.configurations.find_db_config('development')
    Veksel::Commands::Clean.new(db).perform
  end
end
