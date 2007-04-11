#== Synopsis
#
#This class represents a reference to an object in the R interpreter. It 
#also holds a conversion mode used if the RObj represents a callable function.
#RObj objects can be passed to R functions called from Ruby and are the 
#default return type if RSRuby cannot convert the returned results of an R 
#function.
#
#--
# == Author
# Alex Gutteridge
#
# == Copyright
#Copyright (C) 2006 Alex Gutteridge
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

class RObj

  attr_accessor :conversion, :wrap

  def as_r
    self
  end

  #Attempts to call the RObj with the arguments given. Returns the result
  #of calling the R object. Only use this method if the RObj represents an
  #R function.
  def call(*args)
    if @wrap
      e = RSRuby.get_default_mode
      RSRuby.set_default_mode(@wrap)
      ret = self.lcall(RSRuby.convert_args_to_lcall(args))
      RSRuby.set_default_mode(e)
    else
      ret = self.lcall(RSRuby.convert_args_to_lcall(args))
    end
    return ret
  end

  #Sets the conversion mode for this RObj (only relevant if the RObj
  #represents a function). See the constants in RSRuby for valid modes.
  #Returns the current conversion mode if called with no argument.
  def autoconvert(m=false)
    if m
      raise ArgumentError if m < -1 or m > RSRuby::TOP_CONVERSION
      @conversion = m
    end
    @conversion      
  end

end


