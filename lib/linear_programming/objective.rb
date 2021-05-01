module LinearProgramming
  class Objective < Function
    def initialize(problem)
      @problem = problem
    end

    def to_row
      row = factors
      row += Array.new(@problem.constraints.size, 0) << 1
      row << 0
    end
  end
end
