module Veksel
  module Commands
    class Fork
      attr_reader :adapter, :source_db, :target_db

      def initialize(db)
        @adapter = Veksel.adapter_for(db.configuration_hash)
        @source_db = adapter.main_database
        @target_db = adapter.db_name_for_suffix(Veksel.suffix)
        raise "Source and target databases cannot be the same" if source_db == target_db
      end

      def perform
        return false unless adapter
        return false if adapter.target_populated?(target_db)

        adapter.kill_connection(source_db)
        adapter.create_database(target_db, template: source_db)

        true
      end
    end
  end
end
