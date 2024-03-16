module Veksel
  module Commands
    class List
      attr_reader :adapter

      def initialize(db)
        @adapter = Veksel.adapter_for(db.configuration_hash)
      end

      def perform
        databases = adapter.forked_databases
        active_branches = Veksel.active_branches

        if databases.empty?
          puts "No databases created by Veksel"
          return
        end

        hash = {}
        databases.each do |database|
          branch = database.sub(adapter.forked_database_prefix, '')
          hash[branch] = database
        end

        longest_branch_name = hash.keys.max_by(&:length).length
        longest_database_name = hash.values.max_by(&:length).length
        puts "Databases created by Veksel:"
        puts ""
        puts "#{'Branch'.ljust(longest_branch_name)}   #{'Database'.ljust(longest_database_name)}   Active"
        inactive_count = 0
        hash.each do |branch, database|
          # Print a formatted string padded to fit the longest branch name
          active = active_branches.include?(branch) ? 'Yes' : 'No'
          inactive_count += 1 if active == 'No'
          puts "#{branch.ljust(longest_branch_name)}   #{database.ljust(longest_database_name)}   #{active}"
        end

        if inactive_count > 0
          puts ""
          puts "Clean inactive databases with bin/rails veksel:clean"
        end
      end
    end
  end
end
