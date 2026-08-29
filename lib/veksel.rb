require "veksel/version"
require "veksel/railtie" if defined?(Rails::Railtie)
require "veksel/suffix"

module Veksel
  class AdapterNotSupported < StandardError; end

  class << self
    def adapter_for(config, exception: true)
      case config[:adapter]
      when 'postgresql'
        require_relative './veksel/pg_cluster'
        Veksel::PgCluster.new(config)
      else
        return unless exception
        raise AdapterNotSupported, "Veksel does not yet support #{config[:adapter]}"
      end
    end

    def current_branch
      branch_from_reflog || branch_from_head
    end

    def active_branches
      `git for-each-ref 'refs/heads/' --format '%(refname)'`.split("\n").map { |ref| ref.sub('refs/heads/', '') }
    end

    def skip_fork?
      suffix.to_s.strip.empty?
    end

    def suffix
      Suffix.new(current_branch).to_s
    end

    private

    def branch_from_reflog
      `git reflog --max-count=1 --pretty=%gs --grep-reflog="checkout: moving from [^[:space:]]* to [^[:space:]]*"`.chomp.split(' ').last
    end

    def branch_from_head
      `git rev-parse --abbrev-ref HEAD`.chomp
    end
  end
end
