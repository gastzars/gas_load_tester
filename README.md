# GasLoadTester

Simple Ruby load test library. Give it a try !

**Warning:** High CPU is needed to run this or you will get an unreliable result. If you are an AWS user, I suggest you to look for spot compute instance for this kind of task.

## Installation

Install it yourself as:

    $ gem install gas_load_tester

## Usage

#### Require the library

```ruby
require 'gas_load_tester'
```

#### For simple usage

```ruby
simple_test = GasLoadTester::Test.new({client: 10000, time: 60})
simple_test.run do
  RestClient.get("https://www.mysite.com", {})
end
simple_test.results
```

#### With html output

```ruby
simple_test = GasLoadTester::Test.new({client: 10000, time: 60})
simple_test.run(output: true, file_name: '/mytest/mysite_result') do
  RestClient.get("https://www.mysite.com", {})
end
```

##### Single test outout is shown as below:

[![Gas load tester single test](http://i216.photobucket.com/albums/cc229/gastzar/solotest.png)](https://github.com/gastzars/gas_load_tester)


#### Group comparison test

```ruby
simple_group_test = GasLoadTester::GroupTest.new([
  {"client" => 100, "time" => 5},
  {"client" => 150, "time" => 10},
  {"client" => 160, "time" => 7}
])
simple_group_test.run(output: true, file_name: '/mytest/mysite_group_result.html') do
  RestClient.get("https://www.mysite.com", {})
end
```

##### Group test outout is shown as below:

[![Gas load tester group test](http://i216.photobucket.com/albums/cc229/gastzar/group_test.png)](https://github.com/gastzars/gas_load_tester)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gastzars/gas_load_tester.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

