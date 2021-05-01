module LinearProgramming
  class Maximization < Objective
    def to_row
      inverse!
      super
    end

    def minimization?
      false
    end
  end
end
