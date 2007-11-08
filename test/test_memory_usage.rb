require 'rsruby'

10000.times do |n|
  puts n
  RSRuby.instance.eval_R("x#{n} = c(1:1000000)")
  RSRuby.instance.shutdown
end

