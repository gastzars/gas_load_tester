module GasLoadTester
  class Result
    attr_accessor :pass, :time, :error
    def initialize(args)
      self.pass = args[:pass]
      self.time = args[:time]
      self.error = args[:error]
    end
  end
end
