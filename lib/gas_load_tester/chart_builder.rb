require 'chartkick'

module GasLoadTester
  include Chartkick::Helper

  class ChartBuilder
    include Chartkick::Helper
    attr_accessor :file_name, :body

    DEFAULT_PAGE_HEAD = "<!DOCTYPE html>"\
                   "<html>"\
                   "<head>"\
                   "<script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>"\
                   "<script src=\"https://www.gstatic.com/charts/loader.js\"></script>"\
                   "<script src=\"https://ankane.github.io/chartkick.js/chartkick.js\"></script>"\
                   "</head>"\
                   "<body>"

    DEFAULT_PAGE_TAIL = "<div style=\"display: block; height: 70px; width: 100%;\"></div>"\
                        "</body>"\
                        "</html>"

    def initialize(args = {})
      args ||= {}
      args[:file_name] ||= args['file_name']
      self.file_name = args[:file_name]
    end

    def save
      file_name = self.file_name
      if file_name == ""
        file_name = "load_result_"+Time.now.to_i.to_s+".html"
      elsif !file_name.end_with?(".html")
        file_name = file_name+".html"
      end
      File.open(file_name, 'w') { |file| file.write(self.body) }
      file_name
    end

    def build_body(test)
      sum_body = build_sum_test(test)

      self.body = DEFAULT_PAGE_HEAD + sum_body + DEFAULT_PAGE_TAIL
    end

    def build_group_body(group_test)
      sum_group_body = group_test.tests.collect{|test|
        build_sum_test(test)
      }.join('<hr style="margin-top: 70px; margin-bottom: 70px;">')

      sum_group_table = build_sum_group_table(group_test)

      self.body = DEFAULT_PAGE_HEAD + sum_group_table + sum_group_body + DEFAULT_PAGE_TAIL
    end

    private

    def build_sum_group_table(group_test)
      "<div style=\"width: 100%; text-align: center; margin-top: 20px; margin-bottom: 20px;\">
         <span style=\"align: center; font-weight: bold; font-size: 20px;\">Comparison summary</span>
       </div>

       <div style=\"width: 100%; display: flex; margin-top: 30px;\">
         <div style=\"width: 20%;\">
         </div>
         <div style=\"width: 100%;\">
           <table style=\"width:100%; border: 1px solid black; border-collapse: collapse; text-align: center;\">
             <tr style=\"border: 1px solid black; border-collapse: collapse;\">
               <th width=\"10%\" style=\"border: 1px solid black; border-collapse: collapse;\">client</th>
               <th width=\"10%\" style=\"border: 1px solid black; border-collapse: collapse;\">time (sec)</th>
               <th width=\"10%\" style=\"border: 1px solid black; border-collapse: collapse;\">clients/sec</th>
               <th width=\"10%\" style=\"border: 1px solid black; border-collapse: collapse;\">average_time (ms)</th>
               <th width=\"15%\" style=\"border: 1px solid black; border-collapse: collapse;\">min_time (ms)</th>
               <th width=\"15%\" style=\"border: 1px solid black; border-collapse: collapse;\">max_time (ms)</th>
               <th width=\"15%\" style=\"border: 1px solid black; border-collapse: collapse;\">success</th>
               <th width=\"15%\" style=\"border: 1px solid black; border-collapse: collapse;\">error</th>
             </tr>
                #{
                  group_data = group_test.tests.collect{|test|
                    [
                      test.client,
                      test.time,
                      test.summary_avg_time.round(4),
                      test.summary_min_time.round(4),
                      test.summary_max_time.round(4),
                      test.summary_success,
                      test.summary_error,
                      test.request_per_second
                    ]
                  }
                  min_avg = group_data.collect{|test_data| test_data[2] }.sort.first
                  max_avg = group_data.collect{|test_data| test_data[2] }.sort.last
                  min_min = group_data.collect{|test_data| test_data[3] }.sort.first
                  max_min = group_data.collect{|test_data| test_data[3] }.sort.last
                  min_max = group_data.collect{|test_data| test_data[4] }.sort.first
                  max_max = group_data.collect{|test_data| test_data[4] }.sort.last
                  group_data.collect{|test_data|
                    test_data[5] = test_data[0] if test_data[5] > test_data[0]
                    "<tr style=\"border: 1px solid black; border-collapse: collapse;\">
                       <td style=\"border: 1px solid black; border-collapse: collapse;\">#{test_data[0]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse;\">#{test_data[1]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse;\">#{test_data[7]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse; #{ 
                         if test_data[2] == min_avg
                           "color: green; font-weight:bold;"
                         elsif test_data[2] == max_avg
                           "color: red; font-weight:bold;"
                         end
                       }\">#{test_data[2]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse; #{
                         if test_data[3] == min_min
                           "color: green; font-weight:bold;"
                         elsif test_data[3] == max_min
                           "color: red; font-weight:bold;"
                         end
                       }\">#{test_data[3]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse; #{
                         if test_data[4] == min_max
                           "color: green; font-weight:bold;"
                         elsif test_data[4] == max_max
                           "color: red; font-weight:bold;"
                         end
                       }\">#{test_data[4]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse; #{
                         "color: green; font-weight:bold;" if test_data[0] == test_data[5]
                       }\">#{test_data[5]}</td>
                       <td style=\"border: 1px solid black; border-collapse: collapse; #{
                         test_data[6] > 0 ? "color: red; font-weight:bold;" : "color: green; font-weight:bold;"
                       }\">#{test_data[6]}</td>
                     </tr>"
                  }.join
                }
           </table>
         </div>
         <div style=\"width: 20%;\">
         </div>
       </div>
       <hr style=\"margin-top: 70px; margin-bottom: 70px;\">"
    end

    def build_sum_test(test)
      chart_body = build_chart(test)
      summary_body = build_summary(test)
      error_body = build_error_table(test)

      chart_body + summary_body + error_body
    end

    def build_summary(test)
      min_time = test.summary_min_time
      max_time = test.summary_max_time
      avg_time = test.summary_avg_time
      success = test.summary_success
      error = test.summary_error

      "<div style=\"width: 100%; text-align: center; margin-top: 20px; margin-bottom: 20px;\">
         <span style=\"align: center; font-weight: bold;\">Summary</span>
       </div>
       <div style=\"width: 100%; display: flex;\">
         <div style=\"width: 100%;\">
         </div>
         <div id=\"summary_time\" style=\"width: 100%; align: center;\">
           <table style=\"width: 100%;\">
             <tbody>
               <tr>
                 <th style=\"font-weight: bold;\">Average</th>
                 <td>#{avg_time.round(4)} ms</td>
               </tr>
               <tr>
                 <th style=\"font-weight: bold;\">Min/Max</th>
                 <td>#{min_time.round(4)} / #{max_time.round(4)} ms</td>
               </tr>
             </tbody>
           </table>
         </div>
         <div id=\"summary_data\" style=\"width: 100%; align: center;\">
           <table style=\"width: 100%;\">
             <tbody>
               <tr>
                 <th style=\"font-weight: bold;\">Success</th>
                 <td>#{success}</td>
               </tr>
               <tr>
                 <th style=\"font-weight: bold;\">Error</th>
                 <td>#{error}</td>
               </tr>
             </tbody>
           </table>
         </div>
         <div style=\"width: 100%;\">
         </div>
       </div>"
    end

    def build_chart(test)
      clients_data = {}
      pass_data = {}
      error_data = {}
      average_time_data = {}
      test.results.each{|key, values|
        clients_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.count
        pass_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.select{|val| val.pass }.count
        error_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.select{|val| !val.pass }.count
        if RUBY_VERSION >= "2.4.0"
          average_time_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.collect(&:time).sum.fdiv(values.size)*1000
        else
          average_time_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.collect(&:time).inject(0){|sum,x| sum + x }.fdiv(values.size)*1000
        end
      }

      line_chart(
        [
          {
            name: 'Clients/sec',
            data: clients_data
          },
          {
            name: 'Passed',
            data: pass_data
          },
          {
            name: 'Error',
            data: error_data
          },
          {
            name: 'Average',
            data: average_time_data
          }
        ],
        {
          adapter: "google",
          "colors": ["#FFD919", "#23FF39", "#FF2A27", "#433DFF"],
          "library": {
            title: "Load test's result (Client: #{test.client}, Time: #{test.time} sec.)",
            legend: {position: 'top'},
            vAxes: {
              0 => {logScale: false, title: 'User (concurrent)'},
              1 => {logScale: false, title: 'Time (ms)', textStyle: {color: 'blue'}}
            },
            series: {
              0 => {targetAxisIndex: 0 },
              1 => {targetAxisIndex: 0 },
              2 => {targetAxisIndex: 0 },
              3 => {targetAxisIndex: 1 },
            }
          }
        }
      )
    end

    def build_error_table(test)
      errors = test.results.collect{|key,values| values.select{|node| node.pass == false}}.flatten
      errors = errors.group_by{|error| "#{error.error.class.to_s}: #{error.error.message}" }
      
      "<div style=\"width: 100%; display: flex; margin-top: 30px;\">
         <div style=\"width: 20%;\">
         </div>
         <div style=\"width: 100%;\">
           <table style=\"width:100%; border: 1px solid black; border-collapse: collapse; text-align: center;\">
             <tr style=\"border: 1px solid black; border-collapse: collapse;\">
               <th width=\"80%\">Error</th>
               <th width=\"20%\">Count</th> 
             </tr>
             #{errors.collect{|_key, _values| 
               "<tr style=\"border: 1px solid black; border-collapse: collapse;\">
                  <td>#{_key}</td>
                  <td>#{_values.count}</td>
                </tr>"
             }.join}
           </table>
         </div>
         <div style=\"width: 20%;\">
         </div>
       </div>"
    end

  end
end 
