module Veksel
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "tasks/veksel_tasks.rake"
    end

    initializer "my_railtie.configure_rails_initialization", before: "active_record.initialize_database" do |app|
      require 'veksel/pg_cluster'
      require 'active_record/database_configurations'

      ActiveRecord::DatabaseConfigurations.register_db_config_handler do |env_name, name, url, config|
        next if url.present?
        next unless env_name == 'development' || env_name == 'test'

        if PgCluster.new(config).target_populated?("#{config[:database]}#{Veksel.suffix}")
          ActiveRecord::DatabaseConfigurations::HashConfig.new(env_name, name, config.merge({
            database: "#{config[:database]}#{Veksel.suffix}"
          }))
        else
          ActiveRecord::DatabaseConfigurations::HashConfig.new(env_name, name, config)
        end
      end
    end
  end
end
