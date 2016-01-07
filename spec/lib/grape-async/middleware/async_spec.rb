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
  
  let(:host) { 'localhost' }
  let(:port) { 3333 }
  
  before(:each) do
    Spec::Support::EndpointFaker::FakerAPI.clear_requests!
  end
  
  context "server async requests", type: :feature do
    
    let(:reqs_tracker) { Spec::Support::EndpointFaker::FakerAPI.requests }
    let(:async_responses) { %w(start start start done done done) }
    let(:sync_responses)  { %w(start done start done start done) }
    
    shared_examples "async requests" do
      
      let(:route) { '/async' }
      
      it "should make 3 thread based async requests" do
        threads = []
        3.times do
          threads << Thread.new {
            `curl -s http://#{host}:#{port}#{route}`
          }
        end
        threads.each(&:join)
        expect(reqs_tracker).to eql(async_responses)
      end

    end

    shared_examples "sync requests" do
      
      let(:route) { '/sync' }
      
      it "should make sync 3 requests" do
        threads = []
        3.times do
          threads << Thread.new {
            `curl -s http://#{host}:#{port}#{route}`
          }
        end
        threads.each(&:join)
        expect(reqs_tracker).to eql(sync_responses)
      end
      
    end
    
    context "using the thin server" do

      before(:all) do
        @server = Thread.new {
          Thin::Server.start('localhost', 3333) { run Spec::Support::EndpointFaker::FakerAPI }
        }
        sleep(1)
      end

      after(:all) do
        @server.kill if @server.is_a?(Thread) and @server.alive?
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
      end

      context "threaded async endpoints are run as async" do
        it_behaves_like "async requests"
      end

      context "EM async endpoints are run as async" do
        it_behaves_like "async requests" do
          let(:route) { '/async_em' }
        end
      end

    end

    context "using the puma server" do

      before(:all) do
        @server = Thread.new {
          app = Spec::Support::EndpointFaker::FakerAPI.new
          Puma::Server.new(app).tap do |s|
            s.add_tcp_listener 'localhost', 3333
          end.run
        }
      end

      after(:all) do
        @server.kill if @server.is_a?(Thread) and @server.alive?
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
      end

      context "threaded async endpoints are run as async" do
        it_behaves_like "async requests"
      end

      context "EM async endpoints are run as async" do
        it_behaves_like "async requests" do
          let(:route) { '/async_em' }
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
          Rack::Handler::WEBrick.run(Spec::Support::EndpointFaker::FakerAPI.new, :Port => 3333)
        }
        sleep(1)
      end

      after(:all) do
        @server.kill if @server.is_a?(Thread) and @server.alive?
      end

      context "sync endpoints are run as sync" do
        it_behaves_like "sync requests"
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

    context "async endpoints" do
      it "should pass through the async middleware" do
        expect_any_instance_of(Grape::Async).to receive(:call!).and_return([-1, {}, []])
        get '/async'
      end

      it "should receive async response" do
        setup_async_obj!
        get '/async'
        expect(last_response.status).to eq(-1)
      end

      it "should NOT receive async response without server asysnc support" do
        get '/async'
        expect(last_response.status).to eq(200)
      end
    end

    context "sync endpoints" do
      it "should pass through the async middleware" do
        expect_any_instance_of(Grape::Async).to receive(:call!).and_return([200, {}, ['ok']])
        get '/sync'
      end

      it "should NOT receive async response" do
        get '/sync'
        expect(last_response.status).to eq(200)
      end

      it "should NOT receive async response without server asysnc support" do
        get '/sync'
        expect(last_response.status).to eq(200)
      end

    end
  end
  
end