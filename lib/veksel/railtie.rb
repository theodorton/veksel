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
        veksel_adapter = Veksel.adapter_for(config, exception: false)
        next unless veksel_adapter

        database_name = veksel_adapter.db_name_for_suffix(Veksel.suffix)
        next unless veksel_adapter.target_populated?(database_name)

        ActiveRecord::DatabaseConfigurations::HashConfig.new(env_name, name, config.merge({
          database: database_name,
          veksel_main_database: config[:database],
        }))
      end
    end
  end
end
