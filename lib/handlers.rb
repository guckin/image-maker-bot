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

  def page_subscription(parsed_body)
    halt 404 unless parsed_body[:object] == 'page'
  end

  def handle_message_entries
    parsed_body = json request.body.read
    page_subscription parsed_body
    parsed_body[:entry].each { |entry| yield entry }
  end

  def json(json)
    hash = JSON.parse(json)
    hash.keys
        .map(&:to_sym)
        .zip(hash.values)
        .to_h
  rescue => error
    halt 400, {message: error}.to_json
  end

end