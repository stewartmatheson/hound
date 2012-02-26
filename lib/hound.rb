require 'mongo'
require 'json'

class Hound
  
  def call(env)
    rack_request = Rack::Request.new(env)
    send(rack_request.request_method.downcase, rack_request)
    @response
  end

  private

  def db_connection
    Mongo::Connection.new("localhost", 27017).db("hound")
  end

  def post(rack_request)  
    begin
      hound_request = JSON.parse(rack_request.body.read) 
    rescue JSON::ParserError, Rack::Lint::LintError
      error("Invalid Document")
      return
    end

    exploaded_path = rack_request.path.split(/\//)
    return if exploaded_path.empty?
    db_collection = db_connection.collection(exploaded_path[1])
    document = db_collection.insert(hound_request)
    response_document = { "_id" => document.to_s }
    @response = [201, {"Content-Type" => "application/json"}, [JSON.generate(response_document)]]
  end

  def get(rack_request)
    exploaded_path = rack_request.path.split(/\//)
    return if exploaded_path.empty?
    db_collection = db_connection.collection(exploaded_path[1])
    
    fetched_collection = Array.new
    db_collection.find().each { |doc| fetched_collection << transform_doc(doc) }
    @response = [200, {"Content-Type" => "application/json"}, [JSON.generate(fetched_collection)]]
  end

  def error(message)
    document = {
      :code     => "500",
      :message  => message
    }
    @response = [500, {"Content-Type" => "application/json"}, [document]]
  end

  def transform_doc(doc)
    new_doc = Hash.new
    doc.each { |key, value| new_doc[key] = value.to_s }
    new_doc
  end

end
