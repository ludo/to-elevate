require File.join( File.dirname(__FILE__), "..", "spec_helper" )

module ContextSpecHelper
  def valid_properties
    { :name => "calls",
      :user_id => 1 }
  end
end

describe Context, "properties" do
  include ContextSpecHelper
  
  describe "with a name" do
    before(:each) do
      @context = Context.new(valid_properties)
    end    
    
    it "should be valid" do
      @context.should be_valid
    end
    
    it "should not exceed the maximum length of 32 characters" do
      @context.name = "abc" * 15
      @context.should_not be_valid
      @context.errors.on(:name).should_not be_nil
    end
    
    it "should return the name when stringified" do
      @context.to_s.should == @context.name
    end
  end
  
  describe "without a name" do
    before(:each) do
      @context = Context.new(valid_properties.except(:name))
    end    
    
    it "should not be valid" do
      @context.should_not be_valid
      @context.errors.on(:name).should_not be_nil
    end
  end
  
  describe "with active set to true" do
    before(:each) do
      @context = Context.new(valid_properties.merge(:active => true))
    end
    
    it "should be valid" do
      @context.should be_valid
    end
  end

  describe "with active set to false" do
    before(:each) do
      @context = Context.new(valid_properties.merge(:active => false))
    end
    
    it "should be valid" do
      @context.should be_valid
    end
  end
end

describe Context, "toggling" do
  include ContextSpecHelper

  before(:each) do
    @context = Context.new(valid_properties)
  end

  it "should toggle active" do
    @context.active.should == true
    @context.toggle
    @context.active.should == false
    @context.toggle
    @context.active.should == true
  end
end