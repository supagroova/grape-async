require 'spec_helper'

describe Grape::Middleware::Async do

  subject { Class.new(Grape::API) }
  
  describe "#call!" do
    
    context "with eventmachine" do

      it "should run multiple requests asynchronously" do
      end

    end

    context "with threads" do

      it "should run multiple requests asynchronously" do
      end

    end
    
  end
  
  describe "#async_io" do
    
    context "using the thin server" do

      it "should return an object" do
      end

    end

    context "using the puma server" do

      it "should return an object" do
      end

    end
    
    context "using the passenger server" do

      xit "should return an object" do
      end

    end
    
    context "using the webrick server" do

      it "should not return an object" do
      end

    end
    
  end
  
end