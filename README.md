# Linear Programming
Linear Programming in Ruby.

## Installation

### Gemfile
```ruby
gem 'linear_programming', :github => 'sytse/linear_programming'
```

## Usage
```ruby
problem = LinearProgramming::Problem.new

problem.minimize do |function|
  function.coefficient 4, :x
  function.coefficient 3, :y
end

problem.constraint do |function|
  function.coefficient 3, :x
  function.coefficient 6, :y

  function >= 10
end

problem.optimal_value #=> 5

problem.optimal_solution(:x) #=> 0
problem.optimal_solution(:y) #=> (5/3)
```

### Using lp_solve
#### Installation
```bash
brew install lp_solve
```

#### Require
```ruby
require 'linear_programming/solvers/lp_solve'
```
