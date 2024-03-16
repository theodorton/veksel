namespace :veksel do
  desc "Fork the database from the main branch"
  task :fork do
    require 'veksel/cli'

    Veksel::CLI.fork
  end

  desc "List forked databases"
  task list: 'db:load_config' do
    require 'veksel/commands/list'

    db = ActiveRecord::Base.configurations.find_db_config('development')
    Veksel::Commands::List.new(db).perform
  end

  desc "Delete forked databases"
  task clean: 'db:load_config' do
    require 'veksel/commands/clean'

    db = ActiveRecord::Base.configurations.find_db_config('development')
    Veksel::Commands::Clean.new(db).perform
  end
end
