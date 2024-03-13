module Veksel
  class PgCluster
    attr_reader :database_config

    def initialize(database_config)
      @database_config = database_config
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

    def source_database_name
      database_config[:database]
    end

    def target_database_name
      database_config[:database] + Veksel.suffix
    end

    private

    def pg_connection_args(dbname)
      "-d #{dbname} --no-password"
    end

    def pg_env
      {
        'PGHOST' => database_config[:host],
        'PGPORT' => database_config[:port]&.to_s,
        'PGUSER' => database_config[:username],
        'PGPASSWORD' => database_config[:password],
      }.compact
    end
  end
end
