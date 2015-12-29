require 'spec_helper'

describe Grape::API do

  subject { Class.new(Grape::API) }
  
  describe ".async" do
    
    it "should define route params" do
    end

    it "should not define route params" do
    end

    context "specified with eventmachine" do

      it "should define route params" do
      end

      it "should not define route params" do
      end
      
    end
    
  end
  
end