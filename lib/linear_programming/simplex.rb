class LinearProgramming
  module Simplex    
    MaximumIterations = 1000
    
    module GeneralLinearProgrammingProblem # Phase 1
      def solved?
        @starred_row_indices ||= each_with_index.each_with_object([]) do |(value, row, column), starred_row_indices|
          starred_row_indices << row if value < 0 and column >= free_variable_size
        end
        
        @starred_row_indices.none?
      end
      
      def pivot_column_index
        values = @rows.fetch(@starred_row_indices.first)[0..-2]
        maximum = values.max
        values.index(maximum)
      end
      
      def pivot_row_index
        pivot_row_index = lowest_test_ratio_row_indices.find do |row|
          @starred_row_indices.include?(row)
        end
  
        pivot_row_index ||= lowest_test_ratio_row_indices.first
      end
    end
    
    module StandardMaximizationProblem # Phase 2
      def solved?
        objective.none? do |value|
          value < 0
        end
      end
      
      def pivot_column_index
        minimum = objective.min
        objective.index(minimum)
      end
      
      def pivot_row_index
        lowest_test_ratio_row_indices.first
      end
    end
    
    def solve
      @active_variables = Array.new(row_size) do |row_index|
        row_index + free_variable_size
      end
            
      extend GeneralLinearProgrammingProblem
      pivot until solved?

      extend StandardMaximizationProblem
      pivot until solved?

      Array.new(objective.size) do |column_index|
        if row_index = @active_variables.index(column_index) and @rows.fetch(row_index).fetch(column_index) > 0
          @rows.fetch(row_index).last / @rows.fetch(row_index).fetch(column_index)
        else
          0
        end
      end
    end
    
    private
    def pivot    
      @iteration ||= 0
      @iteration += 1
      raise Infeasible if @iteration > MaximumIterations
      
      @pivot_column_index = pivot_column_index
      @pivot_row_index = pivot_row_index
      
      pivot_row = @rows.fetch(@pivot_row_index)
      pivot_value = pivot_row.fetch(@pivot_column_index)
      
      @rows.each_with_index do |row, row_index|
        next if row_index == @pivot_row_index
        
        product = @rows.fetch(row_index).fetch(@pivot_column_index) / pivot_value
        
        next if product.zero?
        
        row.each_with_index do |value, column_index|
          next if pivot_row.fetch(column_index).zero?
        
          row[column_index] = value - product * pivot_row.fetch(column_index)
        end
      end
      
      @active_variables[@pivot_row_index] = @pivot_column_index
      @starred_row_indices.delete(@pivot_row_index)
    end
    
    def test_ratios
      constraints.map do |constraint|
        denominator = constraint.fetch(@pivot_column_index)
        constraint.last / denominator if denominator > 0
      end
    end
    
    def lowest_test_ratio_row_indices
      raise Unbounded unless lowest_test_ratio = test_ratios.compact.min
    
      test_ratios.each_with_index.each_with_object([]) do |(test_ratio, index), lowest_test_ratio_rows|
        lowest_test_ratio_rows << index if test_ratio == lowest_test_ratio
      end
    end
    
    def constraints
      @rows[0..-2]
    end
    
    def objective
      @rows.last[0..-2]
    end
    
    def free_variable_size
      @free_variable_size ||= column_size - constraints.size - 2
    end
  end
end