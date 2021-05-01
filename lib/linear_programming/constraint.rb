module LinearProgramming
  class Constraint < Function
    attr_reader :operator, :value

    def initialize(problem)
      @problem = problem
    end

    def <=(other)
      @operator = :<=
      @value = other
    end

    def >=(other)
      @operator = :>=
      @value = other
    end

    def to_row
      row = @problem.objective.variables.map do |variable|
        factor(variable, 0)
      end

      constraint_index = @problem.constraints.index(self)
      row += Array.new(@problem.constraints.size + 1, 0).fill(slack_variable, constraint_index, 1)

      row << @value
    end

    private

    def slack_variable
      case @operator
      when :<=
        1
      when :>=
        -1
      end
    end
  end
end
