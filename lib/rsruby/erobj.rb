require 'rsruby'

#== Synopsis
#
#This is an extended RObj class inspired by the example given in the RPy
#manual. Methods caught by method_missing are converted into attribute calls
#on the R object it represents. Also to_s is redefined to print exactly the
#representation used in R.
#
#== Usage
#
#See examples/erobj.rb[link:files/examples/erobj_rb.html] for examples of 
#usage.
#
#--
# == Author
# Alex Gutteridge
#
# == Copyright
#Copyright (C) 2006 Alex Gutteridge
#
# The Original Code is the RPy python module.
#
# The Initial Developer of the Original Code is Walter Moreira.
# Portions created by the Initial Developer are Copyright (C) 2002
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#    Gregory R. Warnes <greg@warnes.net> (RPy Maintainer)
#
#This library is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 2.1 of the License, or (at your option) any later version.
#
#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Lesser General Public License for more details.
#
#You should have received a copy of the GNU Lesser General Public
#License along with this library; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#++

class ERObj

  @@x = 1

  #The ERObj is intialised by passing it an RObj instance which it then stores
  def initialize(robj)
    @robj = robj
    @r    = RSRuby.instance
  end

  #Returns the storred RObj.
  def as_r
    @robj.as_r
  end

  #Returns the Ruby representation of the object according to the basic
  #conversion mode.
  def to_ruby
    @robj.to_ruby(RSRuby::BASIC_CONVERSION)
  end

  #Calls the storred RObj.
  def lcall(args)
    @robj.lcall(args)
  end

  #Outputs the string representation provided by R.
  def to_s

    @@x += 1

    mode = RSRuby.get_default_mode
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    a = @r.textConnection("tmpobj#{@@x}",'w')

    RSRuby.set_default_mode(RSRuby::VECTOR_CONVERSION)
    @r.sink(:file => a, :type => 'output')
    @r.print_(@robj)
    @r.sink.call()
    @r.close_connection(a)

    str = @r["tmpobj#{@@x}"].join("\n")

    RSRuby.set_default_mode(mode)

    return str

  end

  #Methods caught by method_missing are converted into attribute calls on 
  #the R object it represents.
  def method_missing(attr)
    mode = RSRuby.get_default_mode
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    e = @r['$'].call(@robj,attr.to_s)
    RSRuby.set_default_mode(mode)
    return e
  end

end
