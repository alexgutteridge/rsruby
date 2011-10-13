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

File.open("config.h", "w") do |f|
  f.puts("#ifndef R_CONFIG_H")
  f.puts("#define R_CONFIG_H")
  r_home = $configure_args.has_key?('--with-R-dir') ? $configure_args['--with-R-dir'].inspect : 'NULL'
  f.puts("#define RSRUBY_R_HOME #{r_home}")
  f.puts("#endif")
end
$extconf_h = 'config.h'

create_makefile("rsruby_c")
