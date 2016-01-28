![Codeship Build Status](https://codeship.com/projects/db2a23e0-911c-0133-7e94-02f6f3a4e3c7/status?branch=master)

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
