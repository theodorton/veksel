require "test_helper"


class VekselPgClusterTest < ActiveSupport::TestCase
  test "db_name_for_suffix" do
    pg_cluster = Veksel::PgCluster.new({ database: 'veksel_dummy_development' })
    assert_equal 'veksel_dummy_development_somebranch', pg_cluster.db_name_for_suffix('somebranch')
    assert_equal 'veksel_dummy_development', pg_cluster.db_name_for_suffix('')
  end
end
