class Server < Sinatra::Base
  VERIFY_TOKEN = 'bringo'.freeze

  configure :production, :development do
    enable :logging
  end

  def  parse_json(json)
    hash = JSON.parse(json)
    hash.keys
        .map(&:to_sym)
        .zip(hash.values)
        .to_h
  rescue => error
    halt 400, {message: error}.to_json
  end


  get '/' do
    content_type :json
    { health_check: 'ok' }.to_json
  rescue => e
    halt 500, {message: e}.to_json
  end

  post '/webhook' do
    parsed_body = parse_json request.body.read
    halt 404 unless parsed_body[:object] == 'page'
    parsed_body[:entry].each do  |entry|
      logger.info entry
    end
    200
  end

  get '/webhook' do
    mode = params['hub.mode']
    challenge = params['hub.challenge']
    sent_token = params['hub.verify_token']
    halt(500) unless mode && sent_token && challenge
    halt(403) unless mode == 'subscribe' && sent_token == VERIFY_TOKEN
    challenge
  end
end