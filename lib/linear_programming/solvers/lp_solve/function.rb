module LinearProgramming
  class Function
    def to_s
      map { |variable, factor| "#{factor.to_f} x#{@problem.objective.variables.index(variable)}" }.join('+')
    end
  end
end
