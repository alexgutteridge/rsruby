require 'mkmf'

dir_config('R')
unless have_library("R")
  $stderr.puts "\nERROR: Cannot find the R library, aborting."
  exit 1
end
unless have_header("R.h")
  $stderr.puts "\nERROR: Cannot find the R header, aborting."
  exit 1
end

create_makefile("rsruby")
