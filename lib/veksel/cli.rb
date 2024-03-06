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

      config = Psych.safe_load(File.read('config/database.yml'), aliases: true)['development'].transform_keys(&:to_sym)
      target_database = config[:database] + Veksel.suffix
      db = OpenStruct.new(configuration_hash: config, database: target_database)
      Veksel::Commands::Fork.new(db).perform

      duration = ((Time.now.to_f - t1) * 1000).to_i
      FileUtils.touch('tmp/restart.txt')
      puts "Forked database in #{duration.to_i}ms"
    end
  end
end
