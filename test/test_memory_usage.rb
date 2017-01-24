require 'rsruby'
10000.times do |n|
  a = RSRuby.instance.parse(:text =>"x#{n} = c(1:1000000);")
  RSRuby.instance.eval(a)
  RSRuby.instance.eval_R("rm(x#{n})")
#RSRuby.instance.eval_R("x#{n} = c(1:1000000)")
end

RSRuby.instance.shutdown

