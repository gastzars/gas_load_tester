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

    DEFAULT_PAGE_TAIL = "</body>"\
                        "</html>"
    def initialize(args = {})
      args[:file_name] ||= args['file_name']
      self.file_name = args[:file_name]
    end

    def save
      file_name = self.file_name
      if file_name == ""
        file_name = "load_result_"+Time.now.to_i.to_s+".html"
      elsif file_name.end_with?(".html")
        file_name = file_name+".html"
      end
      File.open(self.file_name, 'w') { |file| file.write(self.body) }
      file_name
    end

    def build_body(test)
      chart_body = build_chart(test)
      summary_body = build_summary(test)
      error_body = build_error_table(test)

      self.body = DEFAULT_PAGE_HEAD + chart_body + summary_body + error_body + DEFAULT_PAGE_TAIL
    end

    private

    def build_summary(test)
      avg_time = test.results.collect{|key, values| values.collect(&:time) }.flatten
      min_time = avg_time.sort.first*1000
      max_time = avg_time.sort.last*1000
      avg_time = avg_time.sum.fdiv(avg_time.size)*1000
      success = test.results.collect{|key, values| values.select{|val| val.pass }.count }.flatten.sum
      error = test.results.collect{|key, values| values.select{|val| !val.pass }.count }.flatten.sum

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
        average_time_data[Time.at(key).utc.strftime("%H:%M:%S")] = values.collect(&:time).sum.fdiv(values.size)*1000
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
            title: "Load test's result",
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
