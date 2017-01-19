require 'ruby-progressbar'
require 'thwait'

module GasLoadTester
  class Test
    attr_accessor :user, :time, :results

    DEFAULT = {
      user: 1000,
      time: 300
    }

    def initialize(args = {})
      args[:user] ||= args['user']
      args[:time] ||= args['time']
      args = DEFAULT.merge(args)

      self.user = args[:user]
      self.time = args[:time]
      self.results = {}
    end

    def run(args = {}, &block)
      args[:graph] ||= args['graph']
      args[:file_name] ||= args['file_name']
      @progressbar = ProgressBar.create(
        :title => "Load test",
        :starting_at => 0,
        :total => self.time+10,
        :format => "%a %b\u{15E7}%i %p%% %t",
        :progress_mark  => ' ',
        :remainder_mark => "\u{FF65}"
      )
      load_test(block)
      if args[:graph]
        export_file({file_name: args[:file_name]})
      end
    end

    def request_per_second
      (self.user/self.time.to_f).ceil
    end

    def export_file(args = {})
      file = args[:file_name] || ''
      chart_builder = GasLoadTester::ChartBuilder.new(file_name: file)
      chart_builder.build_body(self)
      chart_builder.save
    end

    private

    def load_test(block)
      threads = []
      rps = request_per_second
      self.time.times do |index|
        self.results[index] = []
        start_index_time = Time.now
        rps.times do
          threads << Thread.new do
            begin
              start_time = Time.now
              block.call
              self.results[index] << build_result({pass: true, time: Time.now-start_time})
            rescue => error
              self.results[index] << build_result({pass: false, error: error, time: Time.now-start_time})
            end
          end
        end
        cal_sleep = 1-(Time.now-start_index_time)
        cal_sleep = 0 if cal_sleep < 0
        sleep(cal_sleep)
        @progressbar.increment
      end
      ThreadsWait.all_waits(*threads)
      @progressbar.progress += 10
    end

    def build_result(args)
      Result.new(args)
    end

  end
end
