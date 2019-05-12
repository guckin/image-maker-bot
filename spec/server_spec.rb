require 'rack/test'

class Request

  def initialize(app)
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  def get(route)
    Response.new make_request method: :get, route: route
  end

  def post(route, body)
    Response.new make_request method: :post, route: route, body: body
  end

  private

  def make_request(method:, route:, body: nil)
    args = [method, route]
    args << body if body
    @browser.send *args
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

  describe 'GET /' do

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

  describe 'POST /webhook' do

    before :all do
      @result = request.post '/webhook', {
          "object": "page",
          "entry":
              [
                  {"messaging": [{"message": "TEST_MESSAGE"}]}
              ]
      }
    end

    it 'works' do
      expect(@result).to be_truthy
    end
  end
end