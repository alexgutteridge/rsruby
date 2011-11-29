require 'mkmf'

dir_config('R')

some_paths = ENV['PATH'].split(File::PATH_SEPARATOR) + %w[
  /usr/local/lib64/R
  /usr/local/lib/R 
  /usr/lib64/R 
  /usr/lib/R 
  /Library/Frameworks/R.framework/Resources
]

some_lib_paths = some_paths.map{|dir| File.join(dir, 'lib') }
find_library('R', nil, *some_lib_paths)

unless have_library("R")
  $stderr.puts "\nERROR: Cannot find the R library, aborting."
  exit 1
end

some_include_paths = some_paths.map{|dir| File.join(dir, 'include') } + %w[/usr/include/R]
find_header('R.h', nil, *some_include_paths)

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
