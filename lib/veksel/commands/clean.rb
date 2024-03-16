module Veksel
  module Commands
    class Clean
      def initialize(db, dry_run: false)
        @adapter = Veksel.adapter_for(db.configuration_hash)
        @dry_run = dry_run
      end

      def perform
        all_databases = @adapter.forked_databases
        active_branches = Veksel.active_branches

        stale_databases = all_databases.filter do |database|
          active_branches.none? { |branch| database.branch == branch }
        end
        stale_databases.each do |database|
          @adapter.drop_database(database.name, dry_run: @dry_run)
        end
      end
    end
  end
end
