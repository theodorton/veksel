require_relative '../pg_cluster'

module Veksel
  module Commands
    class Fork
      attr_reader :pg_cluster, :source_db, :target_db

      def initialize(db)
        @pg_cluster = PgCluster.new(db.configuration_hash)
        @source_db = db.database.sub(%r[#{Veksel.suffix}$], '')
        @target_db = db.database
        raise "Source and target databases cannot be the same" if source_db == target_db
      end

      def perform
        return if pg_cluster.target_populated?(target_db)

        ActiveSupport::Notifications.instrument "veksel.fork", source: source_db, target: target_db do
          pg_cluster.transfer(from: source_db, to: target_db)
        end
      end
    end
  end
end
