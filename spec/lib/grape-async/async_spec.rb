require 'spec_helper'
require 'eventmachine'
require 'thin'
require 'puma'

describe Grape::Async do

  def setup_async_obj!
    async_obj = double(:async_obj)
    allow(async_obj).to receive(:call)
    allow_any_instance_of(Grape::Async).to receive(:async_io) {
      async_obj
    }
  end
  
  def kill_server
    @server.kill if @server.is_a?(Thread) and @server.alive?
  end
  
  def port
    3333
  end
  
  let(:host)  { 'localhost' }
  let(:delay) { 0.25 }
  
  before(:each) do
    Spec::Support::EndpointFaker::FakerAPI.clear_requests!
  end
  
  context "server async requests", type: :feature do
    
    let(:reqs_tracker)    { Spec::Support::EndpointFaker::FakerAPI.requests }
    let(:async_responses) { %w(start:1 start:2 start:3 done:1 done:2 done:3) }
    let(:sync_responses)  { %w(start:1 done:1 start:2 done:2 start:3 done:3) }
    
    shared_examples "async requests" do

      let(:route) { '/async' }

      it "should make 3 thread based async requests" do
        threads = []
        counter = 0
        expect(@server).to be_alive
        Timeout::timeout(delay * 5) do
          3.times do
            threads << Thread.new {
              counter += 1
              uri = URI.parse("http://#{host}:#{port}#{route}?counter=#{counter}&delay=#{delay}")
              Net::HTTP.get_response(uri)
            }
            sleep(delay / 3.0)
          end
        end
        threads.each(&:join)
        expect(reqs_tracker).to eql(async_responses)
      end

    end

    shared_examples "error requests" do

      let(:route) { '/async_error' }
      it "should return a 400 missing parameter response" do
        Timeout::timeout(delay * 4) {
          uri = URI.parse("http://#{host}:#{port}#{route}")
          response = Net::HTTP.get_response(uri)
          expect(response.code).to eq('400')
        }
      end

      it "should return a 500 missing parameter response" do
        Timeout::timeout(delay * 4) {
          uri = URI.parse("http://#{host}:#{port}#{route}?counter=1")
          response = Net::HTTP.get_response(uri)
          expect(response.code).to eq('500')
        }
      end

    end

    shared_examples "sync requests" do
      
      let(:route) { '/sync' }
      
      it "should make sync 3 requests" do
        threads = []
        counter = 0
        3.times do
          threads << Thread.new {
            counter += 1
            uri = URI.parse("http://#{host}:#{port}#{route}?counter=#{counter}")
            Net::HTTP.get_response(uri)
          }
          sleep(delay/3.0)
        end
        threads.each(&:join)
        expect(reqs_tracker).to eql(sync_responses)
      end
      
    end
    
    context "using the thin server" do

      before(:all) do
        @server = Thread.new {
          Thin::Server.start('localhost', port) { run Spec::Support::EndpointFaker::FakerAPI }
        }
        sleep(1)
      end

      after(:all) do
        kill_server
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
        it_behaves_like "error requests" do
          let(:route) { '/sync_error' }
        end
      end

      context "threaded async endpoints are run as async" do
        it_behaves_like "async requests"
        it_behaves_like "error requests"
      end

      context "EM async endpoints are run as async" do
        it_behaves_like "async requests" do
          let(:route) { '/async_em' }
        end
        it_behaves_like "error requests" do
          let(:route) { '/async_em_error' }
        end
      end

    end

    context "using the puma server" do

      before(:all) do
        app  = Spec::Support::EndpointFaker::FakerAPI.new
        puma = Puma::Server.new(app).tap do |s|
          s.add_tcp_listener 'localhost', port
        end
        puma.run
        @server = puma.thread
        sleep(1)
      end

      after(:all) do
        kill_server
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
        it_behaves_like "error requests" do
          let(:route) { '/sync_error' }
        end
      end

      context "threaded async endpoints are run as async" do
        it_behaves_like "async requests"
        it_behaves_like "error requests"
      end

      context "EM async endpoints are run as async" do
        it_behaves_like "async requests" do
          let(:route) { '/async_em' }
        end
        it_behaves_like "error requests" do
          let(:route) { '/async_em_error' }
        end
      end

    end

    context "using the passenger server" do

      pending "Requires passenger support for Capybara"
      # it_behaves_like "async requests"

    end

    context "using the webrick server" do

      before(:all) do
        @server = Thread.new {
          Rack::Handler::WEBrick.run(Spec::Support::EndpointFaker::FakerAPI.new, :Port => port)
        }
        sleep(1)
      end

      after(:all) do
        kill_server
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
        it_behaves_like "error requests" do
          let(:route) { '/sync_error' }
        end
      end

      context "async endpoints are run as sync" do
        let(:route) { '/async' }
        it_behaves_like "sync requests"
      end

    end

  end

  describe "#call!" do

    let(:app) {
      Rack::Builder.new do
        run Spec::Support::EndpointFaker::FakerAPI.new
      end
    }
    let(:counter) { 1 }

    context "async endpoints" do
      it "should pass through the async middleware" do
        expect_any_instance_of(Grape::Async).to receive(:call!).and_return([-1, {}, []])
        get '/async'
      end

      it "should receive async response" do
        setup_async_obj!
        get '/async', counter: counter, delay: delay
        expect(last_response.status).to eq(-1)
      end

      it "should NOT receive async response without server asysnc support" do
        get '/async', counter: counter, delay: delay
        expect(last_response.status).to eq(200)
      end
    end

    context "sync endpoints" do
      it "should pass through the async middleware" do
        expect_any_instance_of(Grape::Async).to receive(:call!).and_return([200, {}, ['ok']])
        get '/sync', counter: counter
      end

      it "should NOT receive async response" do
        get '/sync', counter: counter
        expect(last_response.status).to eq(200)
      end

      it "should NOT receive async response without server asysnc support" do
        get '/sync', counter: counter
        expect(last_response.status).to eq(200)
      end

    end
  end
  
end