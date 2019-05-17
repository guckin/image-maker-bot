require 'rack/test'

class Request

  def initialize(app)
    @browser = Rack::Test::Session.new(Rack::MockSession.new(app))
  end

  def get(*args)
    Response.new @browser.get *args
  end

  def post(*args)
    Response.new @browser.post *args
  end

  private

  def make_request(method:, route:, body: nil, headers: nil)
    arguments = [method, route]
    arguments << body if body
    arguments << headers if headers
    @browser.send *arguments
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
verify_token = server_const::VERIFY_TOKEN
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

    it 'responds with a 200 when the request was successful' do
      body = {
          "object": "page",
          "entry":
              [
                  {"messaging": [{"message": "TEST_MESSAGE"}]}
              ]
      }.to_json
      result = request.post '/webhook', body
      expect(result.status).to eq 200
    end

    it 'responds with a 400 when the request provides bad json' do
      body = 'not json'
      result = request.post '/webhook', body
      expect(result.status).to eq 400
    end

    it 'responds with 404 when the request is not for page' do
      body = {}.to_json
      result = request.post '/webhook', body
      expect(result.status).to eq 404
    end
  end

  describe 'GET /webhook' do

    it 'responds with the challenge' do
      challenge = 'CHALLENGE_ACCEPTED'
      result = request.get '/webhook',
                            'hub.verify_token' => verify_token,
                            'hub.challenge' => challenge,
                            'hub.mode' => 'subscribe'
      expect(result.status).to eq 200
      expect(result.body).to eq challenge
    end

    it 'responds with a 500 when there is not mode in the request' do
      challenge = 'CHALLENGE_ACCEPTED'
      result = request.get '/webhook',
                            'hub.verify_token' => verify_token,
                            'hub.challenge' => challenge

      expect(result.status).to eq 500
    end

    it 'responds with a 500 when no token is sent' do
      challenge = 'CHALLENGE_ACCEPTED'
      result = request.get '/webhook',
                           'hub.challenge' => challenge,
                           'hub.mode' => 'subscribe'

      expect(result.status).to eq 500
    end

    it 'responds with a 500 when no challenge is sent' do
        result = request.get '/webhook',
                             'hub.verify_token' => verify_token,
                             'hub.mode' => 'subscribe'
        expect(result.status).to eq 500
    end

    it 'responds with a 403 if the mode is not subscribe' do
      challenge = 'CHALLENGE_ACCEPTED'
      result = request.get '/webhook',
                           'hub.verify_token' => verify_token,
                           'hub.challenge' => challenge,
                           'hub.mode' => 'not subscribe'
      expect(result.status).to eq 403
    end

    it 'responds with a 403 if the token is incorrect' do
      challenge = 'CHALLENGE_ACCEPTED'
      result = request.get '/webhook',
                           'hub.verify_token' => 'NOT THE CORRECT TOKEN',
                           'hub.challenge' => challenge,
                           'hub.mode' => 'subscribe'
      expect(result.status).to eq 403
    end
  end
end