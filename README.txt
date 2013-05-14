== Introduction

RSRuby is a bridge library for Ruby giving Ruby developers access to the full R statistical programming environment. RSRuby embeds a full R interpreter inside the running Ruby script, allowing R methods to be called and data passed between the Ruby script and the R interpreter. Most data conversion is handled automatically, but user-definable conversion routines can also be written to handle any R or Ruby class.

RSRuby is a partial conversion of RPy[http://rpy.sourceforge.net/], and shares the same goals of robustness, ease of use and speed. The current version is stable and passes 90% of the RPy test suite. Some conversion and method calling semantics differ between RPy and RSRuby (largely due to the differences between Python and Ruby), but they are now largely similar in functonality.

Major things to be done in the future include proper handling of OS signals, user definable I/O functions, improved DataFrame support and inevitable bug fixes.

== Installation

A working R installation is required. R must have been built with the '--enable-R-shlib' option enabled to provide the R shared library used by RSRuby.

Ensure the R_HOME environment variable is set appropriately. E.g.:

  R_HOME=/usr/lib/R (on Ubuntu Linux)
  R_HOME=/Library/Frameworks/R.framework/Resources (on OS X)
  R_HOME=/usr/local/Cellar/r/2.13.2/R.framework/Resources ( on OS X installing R with homebrew )

An RSRuby gem is available as well as a package using setup.rb. In each case the installation requires the location of your R library to compile the extension. This is usually the same as R_HOME. If you download the setup.rb package use these incantations:

  ruby setup.rb config -- --with-R-dir=$R_HOME
  ruby setup.rb setup
  ruby setup.rb install

Using gems it is almost the same:

  gem install rsruby -- --with-R-dir=$R_HOME

If RSRuby does not compile correctly you may need to configure the path to the R library, any one of the following should be sufficient:

o Put the following line in your .bashrc (or equivalent):

  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:RHOME/bin

o or, make a link to RHOME/bin/libR.so in /usr/local/lib or /usr/lib, then run 'ldconfig'.

o or, edit the file /etc/ld.so.conf, add the following line and then run 'ldconfig':

  RHOME/bin

== Documentation

There are a few sources of documentation for RSRuby, though the manual should be considered the authoritative text.

Manual:: The manual[http://web.kuicr.kyoto-u.ac.jp/~alexg/rsruby/manual.pdf] has most of the comprehensive information on calling R functions and the conversion system.
Examples:: A few example scripts are included in the distribution:
* Using Arrayfields[link:files/examples/arrayfields_rb.html] instead of Hash for named lists/vectors.
* Using the Bioconductor[link:files/examples/bioc_rb.html] library.
* An example[link:files/examples/dataframe_rb.html] using the DataFrame class.
* An example[link:files/examples/erobj_rb.html] using the ERObj class.
Tests:: The test scripts also show several usage examples.

Finally, here is a very quick and simple example:

 #Initialize R
 require 'rsruby'

 #RSRuby uses Singleton design pattern so call instance rather
 #than new
 r = RSRuby.instance
 #Call R functions on the r object
 data = r.rnorm(100)
 r.plot(data)
 sleep(2)
 #Call with named args
 r.plot({'x' => data,
         'y' => data,
         'xlab' => 'test',
         'ylab' => 'test'})
 sleep(2)

== License

Copyright (C) 2006 Alex Gutteridge

The Original Code is the RPy python module.

The Initial Developer of the Original Code is Walter Moreira.
Portions created by the Initial Developer are Copyright (C) 2002
the Initial Developer. All Rights Reserved.

Contributor(s):
Gregory R. Warnes <greg@warnes.net> (RPy Maintainer)

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
