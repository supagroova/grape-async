require '../lib/grape-async'

class API < Grape::API
  use Grape::Middleware::Async
  
  async :em
  desc "Get status using EM async timer"
  get :em do
    puts "Sleeping..."
    EM.add_timer(2) do
      puts "Awake!"
      present({ status: 'ok'})
      done
    end
  end
  
  async :threaded
  desc "Get status using Threaded async timer"
  get :thread do
    puts "Sleeping..."
    sleep(2)
    puts "Awake!"
    present({ status: 'ok'})
  end
  
  desc "Get status using sync timer"
  get :sync do
    puts "Sleeping..."
    sleep(2)
    puts "Awake!"
    present({ status: 'ok'})
  end
  
end

run API.new
