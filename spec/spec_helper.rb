require 'rspec'
require 'rack/test'
require 'rack'
require File.join(File.dirname(__FILE__), '../lib/hound')

COLLECITONS = 'people'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  config.before(:each) do 
    connection = Mongo::Connection.new("localhost", 27017).db("hound")
    connection.drop_collection 'people'
  end    
end

