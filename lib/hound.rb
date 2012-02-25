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

  def error(message)
    document = {
      :code     => "500",
      :message  => message
    }
    @response = [500, {"Content-Type" => "application/json"}, [document]]
  end
end
