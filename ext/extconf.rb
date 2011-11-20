require 'mkmf'

dir_config('R')

some_paths = ENV['PATH'].split(File::PATH_SEPARATOR) + %w[
  /usr/local/lib64/R
  /usr/local/lib/R 
  /usr/lib64/R 
  /usr/lib/R 
  /Library/Frameworks/R.framework/Resources
]

some_lib_paths = some_paths.map{|dir| "#{dir}/lib" }
find_library('R', nil, *some_lib_paths)

unless have_library("R")
  $stderr.puts "\nERROR: Cannot find the R library, aborting."
  exit 1
end

some_include_paths = some_paths.map{|dir| "#{dir}/include" } + %w[/usr/include/R]
find_header('R.h', nil, *some_include_paths)

unless have_header("R.h")
  $stderr.puts "\nERROR: Cannot find the R header, aborting."
  exit 1
end

create_makefile("rsruby_c")
