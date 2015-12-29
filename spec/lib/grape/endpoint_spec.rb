require 'spec_helper'

describe Grape::Endpoint do
  
  subject { Class.new(Grape::API) }
  
  describe "#async_route?" do
    
    it "should return true" do
    end

    it "should return false" do
    end
    
    context "specified with eventmachine" do

      it "should return true" do
      end

      it "should return false" do
      end
      
    end
    
  end
  
end