class LinearProgramming
  def optimal_value
    solution.first
  end
  
  def optimal_solution(variable)
    solution[@objective.variables.index(variable).next]
  end
  
  private  
  def solution
    @solution ||= begin
      solution = `echo "#{to_s}" | lp_solve -presolve 2>&1`
      
      raise Infeasible if solution =~ /contradicts|infeasible/
      raise Unbounded if solution =~ /unbounded/
      
      solution.scan(/[\d+\.e-]+$/).map(&:to_r)
    end
  end
  
  def to_s
    [@objective.to_s, *@constraints.map(&:to_s)].join
  end
  
  class Function
    def to_s
      map { |variable, factor| "#{factor.to_f} x#{@problem.objective.variables.index(variable)}" }.join('+')
    end
  end
  
  class Maximization
    def to_s
      "max: #{super};"
    end
  end
  
  class Minimization
    def to_s
      "min: #{super};"      
    end
  end
  
  class Constraint
    def to_s
      "#{super} #{@operator} #{@value.to_f};"
    end
  end
end