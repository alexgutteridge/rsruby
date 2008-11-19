Gem::Specification.new do |s|
  s.name = %q{rsruby}
  s.version = "0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Gutteridge"]
  s.date = %q{2008-11-19}
  s.description = %q{RSRuby is a bridge library for Ruby giving Ruby developers access to the full R statistical programming environment. RSRuby embeds a full R interpreter inside the running Ruby script, allowing R methods to be called and data passed between the Ruby script and the R interpreter. Most data conversion is handled automatically, but user-definable conversion routines can also be written to handle any R or Ruby class.}
  s.email = %q{ag357@cam.ac.uk}
  s.extensions = ["ext/extconf.rb"]
  s.extra_rdoc_files = ["README.txt", "History.txt", "License.txt", "examples/bioc.rb", "examples/dataframe.rb", "examples/arrayfields.rb", "examples/erobj.rb"]
  s.files = ["History.txt", "License.txt", "Manifest.txt", "README.txt", "Rakefile.rb", "examples/arrayfields.rb", "examples/bioc.rb", "examples/dataframe.rb", "examples/erobj.rb", "ext/Converters.c", "ext/Converters.h", "ext/R_eval.c", "ext/R_eval.h", "ext/extconf.rb", "ext/robj.c", "ext/rsruby.c", "ext/rsruby.h", "lib/rsruby.rb", "lib/rsruby/dataframe.rb", "lib/rsruby/erobj.rb", "lib/rsruby/robj.rb", "test/table.txt", "test/tc_array.rb", "test/tc_boolean.rb", "test/tc_cleanup.rb", "test/tc_eval.rb", "test/tc_extensions.rb", "test/tc_init.rb", "test/tc_io.rb", "test/tc_library.rb", "test/tc_matrix.rb", "test/tc_modes.rb", "test/tc_robj.rb", "test/tc_sigint.rb", "test/tc_to_r.rb", "test/tc_to_ruby.rb", "test/tc_util.rb", "test/tc_vars.rb", "test/test_all.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://web.kuicr.kyoto-u.ac.jp/~alexg/rsruby/}
  s.rdoc_options = ["--exclude", "test/*", "--main", "README.txt", "--inline-source"]
  s.require_paths = ["lib", "test", "ext"]
  s.rubyforge_project = %q{rsruby}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{RSRuby is a bridge library for Ruby giving Ruby developers access to the full R statistical programming environment. RSRuby embeds a full R interpreter inside the running Ruby script, allowing R methods to be called and data passed between the Ruby script and the R interpreter. Most data conversion is handled automatically, but user-definable conversion routines can also be written to handle any R or Ruby class.}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
