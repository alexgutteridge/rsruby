require 'hoe'

$LOAD_PATH.unshift("./lib")
$LOAD_PATH.unshift("./ext")

gem_name = RUBY_PLATFORM !~ /mswin32$/ ? "rsruby" : "rsrubywin"
hoe = Hoe.spec gem_name do 
  
#  author = "Alex Gutteridge, Ben J Woodcroft"
#  email = "ag357@cam.ac.uk, b.woodcroft@pgrad.unimelb.edu.au"
  url = "http://web.kuicr.kyoto-u.ac.jp/~alexg/rsruby/"
  developer 'Aaron Goodman', 'aaron@custora.com'
  description = paragraphs_of("README.txt",1..3)[0]
  summary     = paragraphs_of("README.txt",1)[0]
  changes     = paragraphs_of("History.txt",0..1).join("\n\n")
  
  clean_globs = ["ext/*.o","ext/*.so","ext/Makefile","ext/mkmf.log","**/*~","email.txt","manual.{aux,log,out,toc,pdf}"]
  
#  p.rdoc_pattern = /(^lib\/.*\.rb$|^examples\/.*\.rb$|^README|^History|^License)/
  
  spec_extras = {
    :extensions    => RUBY_PLATFORM !~ /mswin32$/ ? ['ext/extconf.rb'] : [],
    :require_paths => ['lib','test','ext'],       
    :has_rdoc      => true,
    :extra_rdoc_files => ["README.txt","History.txt","License.txt"] + FileList["examples/*"],
    :rdoc_options  => ["--exclude", "test/*", "--main", "README.txt", "--inline-source"]
  }

  task :setup_rb_package => [:clean, :package] do
    
    package_dir = "#{p.name}-#{p.version}"
    cp("setup.rb","pkg/#{package_dir}")
    #cp("manual.pdf","pkg/#{package_dir}")
    
    Dir.chdir("pkg")
    system("tar -czf #{p.name}-#{p.version}.tgz #{package_dir}")
    Dir.chdir("..")

  end

end

hoe.spec.dependencies.delete_if{|dep| dep.name == "hoe"}
if RUBY_PLATFORM =~ /mswin32$/
  # add the precompiled rsruby_c.so into the gemspec
  hoe.spec.files = hoe.spec.files + ["ext/rsruby_c.so"] 
  
  # add the :build_extension task to :gem so that the extension gets
  # built BEFORE packaging (note the task needs to occur first)
  Rake.application.lookup(:gem).prerequisites.unshift(:build_extension)
end

desc "Uses extconf.rb and make to build the extension"
task :build_extension => ['ext/rsruby_c.so']
SRC = FileList['ext/*.c'] + FileList['ext/*.h']
file 'ext/rsruby_c.so' => SRC do
  Dir.chdir('ext')
  if RUBY_PLATFORM !~ /mswin32$/
    system("ruby extconf.rb -- --with-R-dir=$R_HOME --with-R-include=/usr/share/R/include/")
    system("make")
  else
    # Windows-specific build that does not use extconf.rb or make
    # This build was designed using the default One-Click Installer
    # for Windows (1.8.6-25) and MinGW (5.1.3).  Both are freely
    # available.  See the following websites for downloads and
    # installation information:
    # 
    # http://rubyforge.org/projects/rubyinstaller/
    # http://www.mingw.org/
    #
    
    # TODO - 
    # * add checks for installation paths
    # * rewrite this build in terms of rake rules? (or at least check 
    #   so that up-to-date files are not rebuilt)
    # * add configuration options a-la extconf.rb
    
    # Note: here I use slashes '/' rather than backslashes '\' in the paths.
    # If you enter the gcc command into the command prompt, you do NOT 
    # need to use the *nix-style paths.  Here it's necessary so the backslashes
    # aren't treated as character escapes in the ruby strings.
    ruby_install_dir = ENV['RUBY_INSTALL_DIR'] || "C:/ruby"
    ruby_headers_dir = "#{ruby_install_dir}/lib/ruby/1.8/i386-mswin32"
    ruby_lib_dir = "#{ruby_install_dir}/lib"
    
    r_install_dir = ENV['R_INSTALL_DIR'] || "C:/Program Files/R/R-2.6.0"
    r_headers_dir = "#{r_install_dir}/include"
    r_lib_dir = "#{r_install_dir}/bin"
    
    # These defines are all added for a clean compile.   I'm not sure if 
    # setting these flags is appropriate, but they do work.
    # HAVE_R_H:: extconf.rb includes this flag
    # HAVE_ISINF:: prevents "isinf" redefinition
    # _MSC_VER:: prevents "MSC version unmatch" error -- it may not be smart to bypass this check
    # STRICT_R_HEADERS:: prevents "ERROR" redefinition
    defines = "-DHAVE_R_H -DHAVE_ISINF -D_MSC_VER=1200 -DSTRICT_R_HEADERS"
    
    # check required files exist
    [ruby_headers_dir, ruby_lib_dir].each do |dir|
      next if File.exists?(dir)
      raise %Q{
Build Error: 
ruby directory does not exist (#{dir})
Try setting RUBY_INSTALL_DIR to the ruby installation directory.

}
    end
    
    [r_headers_dir, r_lib_dir].each do |dir|
      next if File.exists?(dir)
      raise %Q{
Build Error: 
R directory does not exist (#{dir})
Try setting R_INSTALL_DIR to the R installation directory.

}
    end
    
    OBJ = SRC.collect do |src|
      next unless File.extname(src) == ".c"
      
      # at this point the src files are like 'ext/src.c'
      src = File.basename(src)
      
      # compile each source file, using the same flags as extconf.rb
      # notice the quotes encapsulating the include paths, so that 
      # spaces are allowed (as in the R default install path)
      sh( %Q{gcc -I. -I"#{ruby_headers_dir}" -I"#{r_headers_dir}" #{defines} -g -O2 -c #{src}} )
      
      # double duty... collect the .o filenames
      File.basename(src).chomp(".c") + ".o"
    end.compact
    
    # same notes as extconf.rb
    sh( %Q{gcc -shared -s -L. -Wl,--enable-auto-image-base,--enable-auto-import,--export-all -L"#{ruby_lib_dir}" -L"#{r_lib_dir}" -o rsruby_c.so #{OBJ.join(" ")} -lmsvcrt-ruby18 -lR -lwsock32})
  end
  Dir.chdir('..')
end

task :test => [:build_extension]

desc "Build PDF manual"
task :build_manual => ["manual.pdf"]
file "manual.pdf" => ["manual.tex"] do
  out = 'Rerun'
  while out.match(/Rerun/)
    out = `pdflatex manual.tex`
  end  
end

task :build_manual_clean => [:build_manual] do
  system("rm manual.{aux,log,out,toc}")
end
