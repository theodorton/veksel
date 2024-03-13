require_relative '../pg_cluster'

module Veksel
  module Commands
    class Fork
      attr_reader :pg_cluster, :source_db, :target_db

      def initialize(database_config)
        @pg_cluster = PgCluster.new(database_config)
        @source_db = pg_cluster.source_database_name
        @target_db = pg_cluster.target_database_name

        raise "Source and target databases cannot be the same" if source_db == target_db
      end

      def perform
        return if pg_cluster.target_populated?(target_db)

        pg_cluster.kill_connection(source_db)
        pg_cluster.create_database(target_db, template: source_db)
      end
    end
  end
end
