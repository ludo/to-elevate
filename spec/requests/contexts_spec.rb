require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a context exists" do
  Context.all.destroy!
  request(resource(:contexts), :method => "POST", 
    :params => { :context => { :id => nil }})
end

describe "resource(:contexts)" do
  describe "GET" do
    
    before(:each) do
      @response = request(resource(:contexts))
    end
    
    it "responds successfully" do
      @response.should be_successful
    end

    it "contains a list of contexts" do
      pending
      @response.should have_xpath("//ul")
    end
    
  end
  
  describe "GET", :given => "a context exists" do
    before(:each) do
      @response = request(resource(:contexts))
    end
    
    it "has a list of contexts" do
      pending
      @response.should have_xpath("//ul/li")
    end
  end
  
  describe "a successful POST" do
    before(:each) do
      Context.all.destroy!
      @response = request(resource(:contexts), :method => "POST", 
        :params => { :context => { :id => nil }})
    end
    
    it "redirects to resource(:contexts)" do
      @response.should redirect_to(resource(Context.first), :message => {:notice => "context was successfully created"})
    end
    
  end
end

describe "resource(@context)" do 
  describe "a successful DELETE", :given => "a context exists" do
     before(:each) do
       @response = request(resource(Context.first), :method => "DELETE")
     end

     it "should redirect to the index action" do
       @response.should redirect_to(resource(:contexts))
     end

   end
end

describe "resource(:contexts, :new)" do
  before(:each) do
    @response = request(resource(:contexts, :new))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@context, :edit)", :given => "a context exists" do
  before(:each) do
    @response = request(resource(Context.first, :edit))
  end
  
  it "responds successfully" do
    @response.should be_successful
  end
end

describe "resource(@context)", :given => "a context exists" do
  
  describe "GET" do
    before(:each) do
      @response = request(resource(Context.first))
    end
  
    it "responds successfully" do
      @response.should be_successful
    end
  end
  
  describe "PUT" do
    before(:each) do
      @context = Context.first
      @response = request(resource(@context), :method => "PUT", 
        :params => { :article => {:id => @context.id} })
    end
  
    it "redirect to the article show action" do
      @response.should redirect_to(resource(@context))
    end
  end
  
end

