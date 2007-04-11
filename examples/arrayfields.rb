#==Synopsis
#
#This example shows the use of custom converters to change the default
#RSRuby behaviour. Normally RSRuby converts an R list or vector with the
#name attribute to a Ruby Hash. Ruby Hashes do not conserve order however
#unlike the R datatypes.
#
#To better replicate the R behaviour, this code uses the arrayfields library
#(available as a gem) and the RSRuby Proc conversion mode to create named 
#Arrays which preserve order.
#
#NB: You can run this file like a normal Ruby script. I use some post-
#processing to allow me to add the source to RDoc.
#
#  require 'arrayfields'
#  require 'rsruby'
#
#First we generate a Proc that will return true if we have an R object
#that has the 'names' attribute set:
#
#  test_proc = lambda{|x| !(RSRuby.instance.attr(x,'names').nil?) }
#
#The next Proc takes the R object and generates a new Array with fields
#set appropriately:
#  
#  conv_proc = lambda{|x|
#    hash  = x.to_ruby
#    array = []
#    array.fields = RSRuby.instance.attr(x,'names')
#    RSRuby.instance.attr(x,'names').each{|f| array[f] = hash[f]}
#    return array
#  }
#
#Next we start R, set the t.test function to use Proc conversion and
#add our Procs to the proc_table Hash.
#
#  r = RSRuby.instance
#  r.t_test.autoconvert(RSRuby::PROC_CONVERSION)
#  r.proc_table[test_proc] = conv_proc
#  
#The return values from t.test are now Arrays rather than Hashes:
#
#  ttest = r.t_test([1,2,3])
#  puts ttest.class
#  ttest.each_pair do |field,val|
#    puts "#{field} - #{val}"
#  end
#  puts ttest[1..3]

if __FILE__ == $0
  eval(IO.read($0).gsub(/^\#\s\s/,''))
end
