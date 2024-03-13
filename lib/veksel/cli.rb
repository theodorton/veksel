require 'veksel'

module Veksel
  module CLI
    def self.suffix
      print Veksel.suffix
    end

    def self.fork
      return if Veksel.skip_fork?
      t1 = Time.now.to_f

      require 'veksel/commands/fork'
      require 'psych'
      require 'ostruct'
      require 'fileutils'

      database_config = read_config('config/database.yml')[:development]
      Veksel::Commands::Fork.new(database_config).perform

      duration = ((Time.now.to_f - t1) * 1000).to_i
      FileUtils.touch('tmp/restart.txt')
      puts "Forked database in #{duration.to_i}ms"
    end

    private_class_method def self.read_config(path)
      raw_config = File.read(path)

      if raw_config.include?('<%=')
        require 'erb'
        raw_config = ERB.new(raw_config).result
      end

      Psych.safe_load(raw_config, aliases: true, symbolize_names: true)
    end
  end
end
