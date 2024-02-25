require_relative '../pg_cluster'

module Veksel
  module Commands
    class Clean
      attr_reader :prefix

      def initialize(db, dry_run: false)
        @pg_cluster = PgCluster.new(db.configuration_hash)
        @prefix = Veksel.prefix(db.configuration_hash[:database])
        @dry_run = dry_run
      end

      def perform
        all_databases = @pg_cluster.list_databases(prefix: @prefix)
        stale_databases = all_databases.filter do |database|
          active_branches.none? { |branch| database.end_with?("_#{branch}") }
        end
        stale_databases.each do |database|
          @pg_cluster.drop_database(database, dry_run: @dry_run)
        end
      end

      def active_branches
        `git for-each-ref 'refs/heads/' --format '%(refname)'`.split("\n").map { |ref| ref.sub('refs/heads/', '') }
      end

      def all_databases
        @pg_cluster.list_databases(prefix: @prefix)
      end
    end
  end
end
