#==Synopsis
#
#This example shows the use of the DataFrame class and eval_R to execute some
#Bioconductor code
#
#  require 'rsruby'
#  require 'dataframe'
#
#  r = RSRuby.instance
#
#First we setup the class_table Hash to convert dataframes to Ruby DataFrames
#
#  r.class_table['data.frame'] = lambda{|x| DataFrame.new(x)}
#  RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
#
#Then we load the Bioconductor affy library and use eval_R to run some affy
#code
#
#  r.library('affy')
#
#  r.eval_R("mydata <- ReadAffy()") 
#  r.eval_R("eset.rma <- rma(mydata)")
#  r.eval_R("eset.pma <- mas5calls(mydata)")
#
#frame = r.eval_R("data.frame(exprs(eset.rma), exprs(eset.pma), se.exprs(eset.pma))")
#
#  puts frame.class
#  puts frame.rows.join(" ")
#  puts frame.columns.join(" ")
#
#  puts frame.send('COLD_12H_SHOOT_REP1.cel'.to_sym)

if __FILE__ == $0
  eval(IO.read($0).gsub(/^\#\s\s/,''))
end
