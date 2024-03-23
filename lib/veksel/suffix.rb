module Veksel
  class Suffix
    PROTECTED_BRANCHES = %w[master main].freeze

    def initialize(branch_name)
      @branch_name = branch_name
    end

    def to_s
      case @branch_name
      when 'HEAD'
      when *PROTECTED_BRANCHES
        ""
      else
        @branch_name
      end
    end
  end
end
