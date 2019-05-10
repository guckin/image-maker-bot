require 'rack/test'

class Request

  def initialize(app)
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  def get(route)
    Response.new(make_request method: :get, route: route)
  end

  private

  def make_request(method:, route:)
    @browser.send method, route
  end
end

class Response
  def initialize(response)
    @response = response
  end

  def status
    @response.status
  end

  def body
    return JSON.parse(@response.body) if header['Content-Type'] == 'application/json'
    @response.body
  end

  def header
    @response.header
  end
end

server_const = Server
request = Request.new(server_const)

describe server_const do

  context 'GET /' do

    before :all do
      @result = request.get('/')
    end

    it 'responds with a 200 status' do
      expect(@result.status).to eq 200
    end

    it 'responds with an ok health status' do
      expect(@result.body).to eq({ 'health_check' => 'ok'})
    end
  end
end