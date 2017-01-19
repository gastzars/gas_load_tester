# GasLoadTester

Simple Ruby load test library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gas_load_tester'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gas_load_tester

## Usage

#### For simple usage

```ruby
simple_test = GasLoadTester::Test.new({user: 10000, time: 60})
simple_test.run do
  RestClient.get("https://www.mysite.com", {})
end
```

#### With generated graph

```ruby
simple_test = GasLoadTester::Test.new({user: 10000, time: 60})
simple_test.run(graph: true, file: '/mytest/myste.png') do
  RestClient.get("https://www.mysite.com", {})
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gastzars/gas_load_tester.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
