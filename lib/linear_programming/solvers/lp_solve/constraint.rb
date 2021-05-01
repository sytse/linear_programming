module LinearProgramming
  class Constraint
    def to_s
      "#{super} #{@operator} #{@value.to_f};"
    end
  end
end
