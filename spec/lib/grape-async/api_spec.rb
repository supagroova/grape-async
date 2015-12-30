require 'spec_helper'

describe Grape::API do

  subject { Class.new(Grape::API) }
  
  describe ".async" do
    
    before do
      subject.get('/async') { 'ok' }
    end
    
    let(:route_settings) { subject.route_setting(:async) }
    
    it "should define route settings" do
      subject.async
      expect(route_settings).to be_a(Hash)
      expect(route_settings).to have_key(:async)
      expect(route_settings).to have_key(:async_method)
      expect(route_settings[:async]).to be_truthy
      expect(route_settings[:async_method]).to eql(:threaded)
    end

    it "should not define route params" do
      expect(route_settings).to be_nil
    end

    context "specified with eventmachine" do

      it "should define route params" do
        subject.async :em
        expect(route_settings[:async_method]).to eql(:em)
      end

    end
    
  end
  
end