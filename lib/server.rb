class Server < Sinatra::Base
  include Handlers
  get '/' do
    health_check
  end
end