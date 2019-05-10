class Server < Sinatra::Base
  include Handlers

  get '/', &method(:health_check)
end