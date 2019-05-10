module Handlers

  def self.included(mod)
    mod.extend(self)
  end

 def health_check
   json
   { health_check: 'ok' }
 end

  def json
    content_type :json
  end

end