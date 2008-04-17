require 'drb'
require 'rsruby'

class RSRuby
  include DRb::DRbUndumped
end
  
puts "starting..."
DRb.start_service("druby://:7779", RSRuby)

puts "service started..."
DRb.thread.join
