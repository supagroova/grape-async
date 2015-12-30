require 'spec_helper'

describe Grape::Endpoint do

  subject { Class.new(Grape::API) }
  
  let(:endpoint) { subject.endpoints.first }
  
  describe "#async_route?" do
    
    it "should return true" do
      subject.async
      subject.get('/async') { 'ok' }
      expect(endpoint.async_route?).to be_truthy
    end

    it "should return false" do
      subject.get('/sync') { 'ok' }
      expect(endpoint.async_route?).to be_falsy
    end
    
    context "specified with eventmachine" do

      it "should return true" do
        subject.async :em
        subject.get('/async') { 'ok' }
        expect(endpoint.async_route?).to be_truthy
      end

      
    end
    
  end
  
end