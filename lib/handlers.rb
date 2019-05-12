module Handlers

  def self.included(mod)
    mod.extend(self)
  end

  def health_check
    content_type :json
    { health_check: 'ok' }.to_json
  rescue => e
    halt 500, {message: e}.to_json
  end

  def page_subscription
    halt 404 unless request.body[:object] == 'page'
  end

  def handle_message_entries
    page_subscription
    request.body[:entry].each { |entry| yield entry }
  end

end