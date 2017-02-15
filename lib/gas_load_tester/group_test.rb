module GasLoadTester
  class GroupTest
    attr_accessor :tests
    def initialize(args)
      raise Error.new('An argument should be an Array') unless args.instance_of?(Array)
      self.tests = args.collect{|test_object|
        if test_object.instance_of?(Test)
          test_object
        else
          Test.new test_object
        end
      }
    end

    def run(args = {}, &block)
      args[:output] ||= args['output']
      args[:file_name] ||= args['file_name']
      args[:header] ||= args['header']
      args[:description] ||= args['description']
      args[:stop_when_error] ||= args['stop_when_error']
      args[:error_count_to_stop] ||= args['error_count_to_stop']
      error_counter = 0
      not_run_tests = self.tests.select{|test| !test.is_run? }
      not_run_tests.each_with_index do |test, index|
        print "[#{index+1}/#{not_run_tests.count}] "
        test.run(nil, &block) unless test.is_run?
        error_counter += 1 if error_counter >= 1
        break if error_counter >= (args[:error_count_to_stop] || 3)
        if args[:stop_when_error] == true || !args[:error_count_to_stop].nil?
          error_counter = 1 if error_counter == 0 && test.summary_error > 0
        end
      end
      if args[:output]
        export_file({file_name: args[:file_name], header: args[:header], description: args[:description]})
      end
    end

    def export_file(args = {})
      file = args[:file_name] || ''
      chart_builder = GasLoadTester::ChartBuilder.new(file_name: file, header: args[:header], description: args[:description])
      chart_builder.build_group_body(self)
      chart_builder.save
    end

  end
end
