module LinearProgramming
  class Function < Hash
    alias variables keys
    alias factors values

    alias factor fetch

    def coefficient(factor, variable)
      store(variable, factor)
    end

    def inverse!
      each do |key, value|
        store(key, -value)
      end
    end
  end
end
