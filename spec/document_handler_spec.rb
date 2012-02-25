require 'spec_helper'

describe "Hound document handler" do
  let(:app) { Hound.new }
  let(:connection) { Mongo::Connection.new("localhost", 27017).db("hound") }
 
  context "store a document" do
    let(:person) do
      {
        :first_name => "Fred",
        :last_name  => "Smith",
        :age        => 23,
        :email      => "fred@sameple.com"
      }
    end

    let(:body_input) { StringIO.new(JSON.generate(person)) }
    let(:request_body) { Rack::Lint::InputWrapper.new(body_input) }

    before do
      post '/people', {}, { 'rack.input' => request_body }
      last_response.status.should == 201
    end

    it "has the correct amount of documents" do
      connection.collection('people').count.should == 1
    end
  end
 
  context "should reject a melformed JSON document" do
    let(:person) { "blah" }
    let(:body_input) { StringIO.new(person) }
    let(:request_body) { Rack::Lint::InputWrapper.new(body_input) }

    before do
      post '/people', {}, { 'rack.input' => request_body }
    end
    
    it "should return a http error" do
      last_response.status.should == 500
    end
  end

  context "should reject an empty document" do
    let(:person) { "" }
    let(:body_input) { StringIO.new(person) }
    let(:request_body) { Rack::Lint::InputWrapper.new(body_input) }

    before do 
      post '/people', {}, { 'rack.input' => request_body }
    end

    it "should return a http error" do
      last_response.status.should == 500
    end
  end

  context "should return an id after post" do
    let(:person) do
      {
        :first_name => "Fred",
        :last_name  => "Smith",
        :age        => 23,
        :email      => "fred@sameple.com"
      }
    end

    let(:body_input) { StringIO.new(JSON.generate(person)) }
    let(:request_body) { Rack::Lint::InputWrapper.new(body_input) }

    before do
      post '/people', {}, { 'rack.input' => request_body }
    end

    it "should return the correct json" do
      response_data = JSON.parse(last_response.body)
      response_data['_id'].should eql connection.collection('people').find_one['_id'].to_s
    end
  end
   
  it "should find a document by an ID" do
    let(:person) do
      {
        :first_name => "Fred",
        :last_name  => "Smith",
        :age        => 23,
        :email      => "fred@sameple.com"
      }
    end

    let(:body_input) { StringIO.new(JSON.generate(person)) }
    let(:request_body) { Rack::Lint::InputWrapper.new(body_input) }

    before do
      puts connection.collection('people').insert(person)
      
      get '/people/', {}
    end

    it "should return the correct json" do
      response_data = JSON.parse(last_response.body)
      response_data['_id'].should eql connection.collection('people').find_one['_id'].to_s
    end
  end

  it "should find a list of documents in a collection" do
  end

  it "should present a discoverable list of documents" do
  end

end
