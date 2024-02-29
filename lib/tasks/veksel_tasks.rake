namespace :veksel do
  desc "Fork the database from the main branch"
  task :fork do
    require 'veksel/cli'

    Veksel::CLI.fork
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
