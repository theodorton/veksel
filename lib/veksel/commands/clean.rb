require_relative '../pg_cluster'

module Veksel
  module Commands
    class Clean
      def initialize(db, dry_run: false)
        @pg_cluster = PgCluster.new(db.configuration_hash)
        @dry_run = dry_run
      end

      def perform
        all_databases = @pg_cluster.forked_databases
        active_branches = Veksel.active_branches

        stale_databases = all_databases.filter do |database|
          active_branches.none? { |branch| database.end_with?("_#{branch}") }
        end
        stale_databases.each do |database|
          @pg_cluster.drop_database(database, dry_run: @dry_run)
        end
      end
    end
  end
end
