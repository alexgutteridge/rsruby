#==Synopsis
#
#In this example we intercept the conversion system using the proc conversion
#mode. Instead of converting, every object returned by R is converted to an
#ERObj
#
#  require 'rsruby'
#  require 'rsruby/erobj'
#
#  r = RSRuby.instance
#
#Setting the proc table up with a Proc which always returns true serves to
#intercept the RSRuby conversion system. The conversion system is bypassed
#into the second Proc
#
#  r.proc_table[lambda{|x| true}] = lambda{|x| ERObj.new(x)}
#  RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)
#
#  e = r.t_test([1,2,3,4,5,6])
#
#One feature of ERObj is that they output the same string representation
#as R. We can also access attributes of the R object
#
#  puts e
#  puts "t value: #{e.statistic['t']}"
#

if __FILE__ == $0
  eval(IO.read($0).gsub(/^\#\s\s/,''))
end
