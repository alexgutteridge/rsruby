#==Synopsis
#
#This example shows the use of the Class conversion system to convert
#dataframes into the Ruby DataFrame class
#
#  require 'rsruby'
#  require 'rsruby/dataframe'
#
#  r = RSRuby.instance
#
#Here we just set up a simple class table that returns a new DataFrame
#object when a dataframe is returned by R
#
#  r.class_table['data.frame'] = lambda{|x| DataFrame.new(x)}
#  RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
#
#We then create a dataframe object to test the conversion
#  e = r.as_data_frame(:x => {'foo' => [4,5,6], 'bar' => ['X','Y','Z']})
#
#Using some of the ERObj and DataFrame class capabilities we can access the
#dataframe data in various ways
#
#  puts e
#  puts e.foo.join(" ")
#  puts e.bar.join(" ")
#  puts e.rows.join(" ")
#  puts e.columns.join(" ")
#
#  puts e.baz.join(" ")
#
#  puts e['foo'].join(" ")

if __FILE__ == $0
  eval(IO.read($0).gsub(/^\#\s\s/,''))
end
