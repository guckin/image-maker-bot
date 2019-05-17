class Server < Sinatra::Base
  include Handlers
  get '/' do
    health_check
  end

  post '/webhook' do
    handle_message_entries { |entry| logger.warn entry.to_s }
    200
  end
end