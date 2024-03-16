if defined?(Rails::VERSION)
  if Rails::VERSION::MAJOR < 6
    raise "Veksel requires Rails 6 or later"
  end
end

require "veksel/version"
require "veksel/railtie" if defined?(Rails::Railtie)
require "veksel/suffix"

module Veksel
  class << self
    def current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
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

    def prefix(dbname)
      dbname.sub(%r[#{Veksel.suffix}$], '_')
    end
  end
end
