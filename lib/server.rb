class Server < Sinatra::Base
  include Handlers

  get '/' do
    content_type :json
    health_check
  end
end