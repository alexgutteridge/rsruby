require 'rsruby'

r = RSRuby.instance
r.gctorture(:on => true)

RSRuby.set_default_mode(RSRuby::NO_DEFAULT)

r.c.autoconvert(RSRuby::NO_CONVERSION)    
puts r.typeof(r.c(:foo => 5, :bar => 7))
puts r.attributes(r.c(:foo => 5, :bar => 7))['names'].include?('foo')
puts r.attributes(r.c(:foo => 5, :bar => 7))['names'].include?('bar')
