class Server < Sinatra::Base
  include Handlers
  get '/' do
    health_check
  end

  post '/webhook' do
    handle_message_entries do |entry|
      logger.info entry
    end
  end
end