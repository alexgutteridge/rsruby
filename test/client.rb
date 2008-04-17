require 'drb'

class RException < RuntimeError
end

class RSRuby
  def self.instance
    DRbObject.new(nil, 'druby://127.0.0.1:7779').instance
  end
end
