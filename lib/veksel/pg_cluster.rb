module Veksel
  class PgCluster
    attr_reader :configuration_hash

    def initialize(configuration_hash)
      @configuration_hash = configuration_hash
    end

    def main_database
      configuration_hash[:veksel_main_database] || configuration_hash[:database]
    end

    def forked_databases
      list_databases(prefix: forked_database_prefix)
    end

    def forked_database_prefix
      "#{main_database}_"
    end

    def target_populated?(dbname)
      IO.pipe do |r, w|
        spawn(pg_env, %[psql -t #{pg_connection_args(dbname)} -c "SELECT 'ok' FROM ar_internal_metadata LIMIT 1;"], out: w, err: '/dev/null')
        pid_grep = spawn(pg_env, %[grep -qw ok], in: r, err: '/dev/null')
        w.close
        Process::Status.wait(pid_grep).success?
      end
    end

    def kill_connection(dbname)
      system(pg_env, %[psql #{pg_connection_args('postgres')} -c "select pg_terminate_backend(pid) from pg_stat_activity where datname = '#{dbname}' and pid <> pg_backend_pid();"], exception: true, out: '/dev/null')
    end

    def create_database(dbname, template:)
      system(pg_env, %[createdb --no-password --template=#{template} #{dbname}], exception: true)
    end

    def list_databases(prefix:)
      IO.pipe(autoclose: true) do |r, w|
        sql = %[SELECT datname FROM pg_database WHERE datname LIKE '#{prefix}%'];
        psql = spawn(pg_env, %[psql -t #{pg_connection_args('postgres')} -c "#{sql}"], out: w, err: '/dev/null')
        w.close
        Process::Status.wait(psql)
        r.read.split("\n").map(&:strip)
      end
    end

    def drop_database(dbname, dry_run: false)
      if dry_run
        puts "[Veksel] Would drop database #{dbname}"
      end
      spawn(pg_env, %[dropdb --no-password #{dbname}])
    end

    private

    def pg_connection_args(dbname)
      "-d #{dbname} --no-password"
    end

    def pg_env
      {
        'PGHOST' => configuration_hash[:host],
        'PGPORT' => configuration_hash[:port]&.to_s,
        'PGUSER' => configuration_hash[:username],
        'PGPASSWORD' => configuration_hash[:password],
      }.compact
    end
  end
end
