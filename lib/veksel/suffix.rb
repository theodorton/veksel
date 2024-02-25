module Veksel
  PROTECTED_BRANCHES = %w[master main HEAD].freeze

  class Suffix
    def initialize(branch_name)
      @branch_name = branch_name
    end

    def to_s
      case @branch_name
      when *PROTECTED_BRANCHES
        ""
      else
        "_#{@branch_name}"
      end
    end
  end
end
