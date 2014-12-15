require 'mathn'

require 'linear_programming/simplex'

class LinearProgramming
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
  
  class Function < Hash
    alias :variables :keys
    alias :factors :values
    
    alias :factor :fetch
    
    def coefficient(factor, variable)
      store(variable, factor)
    end
    
    def inverse!
      each do |key, value|
        store(key, -value)
      end
    end
  end
  
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
  
  class Maximization < Objective
    def to_row
      inverse!
      super
    end
  
    def minimization?
      false
    end
  end
  
  class Minimization < Objective
    def minimization?
      true
    end
  end
  
  class Constraint < Function
    attr_reader :operator, :value
    
    def initialize(problem)
      @problem = problem
    end
  
    def <=(value)
      @operator = :<=
      @value = value
    end
    
    def >=(value)
      @operator = :>=
      @value = value
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