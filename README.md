![Codeship Build Status](https://codeship.com/projects/db2a23e0-911c-0133-7e94-02f6f3a4e3c7/status?branch=master)
[![Code Climate](https://codeclimate.com/repos/56a9f6a1b12a0c564e00f8df/badges/9d32be50870d6bf6b2dd/gpa.svg)](https://codeclimate.com/repos/56a9f6a1b12a0c564e00f8df/feed)
[![Test Coverage](https://codeclimate.com/repos/56a9f6a1b12a0c564e00f8df/badges/9d32be50870d6bf6b2dd/coverage.svg)](https://codeclimate.com/repos/56a9f6a1b12a0c564e00f8df/coverage)
[![Issue Count](https://codeclimate.com/repos/567ac1cbbd3f3b0eb800005f/badges/2348ecbd40fc436cb46b/issue_count.svg)](https://codeclimate.com/repos/567ac1cbbd3f3b0eb800005f/feed)

# Async endpoints for Grape APIs

Enable asyncronous endpoints to avoid blocking slow requests within EventMachine or Threads. 
This can be used with any Ruby server supporting `env['async.callback']` or
`env['rack.hijack']` (the Rack Hijack API).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grape', '>= 0.14.0'
gem 'grape-async'
```

## Usage

```ruby
class API < Grape::API
  use Grape::Async
  async
  get do
    # code to run asyncronously ...
  end
end
```

The `async` directive accepts either `:em` for EventMachine based async or `:threaded` for thread based async. 
The default is `:threaded`.

## Examples

To run the provided example with Thin:

```shell
bundle exec thin start -R examples/config.ru
```

or with Puma

```shell
bundle exec puma examples/config.ru -t 8:32 -w 3 -b tcp://0.0.0.0:3000
```

## Contributing

1. Fork it ( https://github.com/stuart/grape-async/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
