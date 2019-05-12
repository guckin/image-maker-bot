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

end