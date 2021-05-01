require_relative 'lp_solve/function'
require_relative 'lp_solve/maximization'
require_relative 'lp_solve/minimization'
require_relative 'lp_solve/constraint'

module LinearProgramming
  class Problem
    def optimal_value
      solution.first
    end

    def optimal_solution(variable)
      solution[@objective.variables.index(variable).next]
    end

    private

    def solution
      @solution ||= begin
        solution = `echo "#{self}" | lp_solve -presolve 2>&1`

        raise Infeasible if /contradicts|infeasible/.match?(solution)
        raise Unbounded if /unbounded/.match?(solution)

        solution.scan(/[\d+.e-]+$/).map(&:to_r)
      end
    end

    def to_s
      [@objective.to_s, *@constraints.map(&:to_s)].join
    end
  end
end
