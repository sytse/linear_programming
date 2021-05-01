module LinearProgramming
  class Problem
    Infeasible = Class.new(ArgumentError)
    Unbounded = Class.new(ArgumentError)

    attr_reader :objective, :constraints

    def initialize
      @constraints = []

      yield self if block_given?
    end

    def maximize
      @objective = Maximization.new(self)

      yield @objective

      @objective
    end

    def minimize
      @objective = Minimization.new(self)

      yield @objective

      @objective
    end

    def constraint
      constraint = Constraint.new(self)
      @constraints << constraint

      yield constraint

      constraint
    end

    def optimal_value
      if @objective.minimization?
        -solution.last
      else
        solution.last
      end
    end

    def optimal_solution(variable)
      solution.fetch(@objective.variables.index(variable))
    end

    private

    def solution
      @solution ||= begin
        tableau = to_tableau
        tableau.extend(Simplex)
        tableau.solve
      end
    end

    def to_tableau
      tableau = @constraints.map(&:to_row)
      tableau << @objective.to_row

      Matrix[*tableau]
    end
  end
end
