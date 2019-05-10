module Handlers

  def self.included(mod)
    mod.extend(self)
  end

 def health_check
   { health_check: 'ok' }.to_json
 end

end