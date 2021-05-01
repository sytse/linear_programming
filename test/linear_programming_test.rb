require 'minitest/autorun'

require_relative '../lib/linear_programming'

module LinearProgrammingTest
  def test_maximization
    problem = LinearProgramming::Problem.new

    problem.maximize do |function|
      function.coefficient 4, :x
      function.coefficient 3, :y
      function.coefficient 2, :z
    end

    problem.constraint do |function|
      function.coefficient 2, :x
      function.coefficient 1, :y
      function.coefficient 1, :z

      function <= 30
    end

    problem.constraint do |function|
      function.coefficient 5, :x
      function.coefficient 2, :z

      function >= 3
    end

    assert_equal 3 / 5, problem.optimal_solution(:x)
    assert_equal 144 / 5, problem.optimal_solution(:y)
    assert_equal 0, problem.optimal_solution(:z)

    assert_equal 444 / 5, problem.optimal_value
  end

  def test_minimization
    problem = LinearProgramming::Problem.new

    problem.minimize do |function|
      function.coefficient 1, :x
      function.coefficient 3 / 4, :y
      function.coefficient 10, :z
    end

    problem.constraint do |function|
      function.coefficient 1, :x
      function.coefficient 1, :y

      function >= 40
    end

    problem.constraint do |function|
      function.coefficient 2, :x
      function.coefficient 1, :y
      function.coefficient -1, :z

      function <= 10
    end

    assert_equal 0, problem.optimal_solution(:x)
    assert_equal 40, problem.optimal_solution(:y)
    assert_equal 30, problem.optimal_solution(:z)

    assert_equal 330, problem.optimal_value
  end

  def test_problem_within_block
    problem = LinearProgramming::Problem.new do |problem|
      problem.maximize do |function|
        function.coefficient 2, :x
        function.coefficient 3, :y
      end

      problem.constraint do |function|
        function.coefficient 6, :x
        function.coefficient 8, :y

        function <= 20
      end
    end

    assert_equal 0, problem.optimal_solution(:x)
    assert_equal 5 / 2, problem.optimal_solution(:y)

    assert_equal 15 / 2, problem.optimal_value
  end

  def test_infeasible_problem
    problem = LinearProgramming::Problem.new

    problem.maximize do |function|
      function.coefficient 1, :x
    end

    problem.constraint do |function|
      function.coefficient 1, :x

      function <= 1
    end

    problem.constraint do |function|
      function.coefficient 1, :x

      function >= 2
    end

    assert_raises LinearProgramming::Problem::Infeasible do
      problem.optimal_solution(:x)
    end
  end

  def test_unbounded_problem
    problem = LinearProgramming::Problem.new

    problem.maximize do |function|
      function.coefficient 1, :x
      function.coefficient 1, :y
    end

    problem.constraint do |function|
      function.coefficient 1, :x

      function <= 3
    end

    assert_raises LinearProgramming::Problem::Unbounded do
      problem.optimal_solution(:x)
    end
  end
end
