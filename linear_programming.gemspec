Gem::Specification.new do |specification|
  specification.name     = 'linear_programming'
  specification.version  = '1.0.0'
  specification.summary  = 'Linear programming in Ruby'
  specification.homepage = 'https://github.com/sytse/linear_programming'
  specification.author   = 'Sytse'

  specification.files = `git ls-files`.split("\n")
  specification.add_dependency 'mathn'
end
