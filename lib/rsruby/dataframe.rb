require 'rsruby'
require 'rsruby/erobj'

#== Synopsis
#
#This is an extended ERObj class inspired by the example given in the RPy
#manual used for R data frames. 
#As with ERObj, methods caught by method_missing are converted into attribute 
#calls on the R dataframe it represents. The rows and columns methods give
#access to the column and row names.
#
#== Usage
#
#See examples/dataframe.rb[link:files/examples/dataframe_rb.html] for 
#examples of usage.
#
#--
#== Author
#Alex Gutteridge
#
#== Copyright
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

class DataFrame < ERObj

  #Returns an array of the row names used in the R data frame.
  def rows
    return @r.attr(@robj, 'row.names')
  end

  #Returns an array of the column names used in the R data frame.
  def columns
    cols = @r.colnames(@robj)
    cols = [cols] unless cols.kind_of?(Array)
    return cols
  end

  #def[](col)
  #  return @r['$'].call(@robj,col.to_s)
  #end

  #Needs to work for named and numbered columns
  def[](row,col)
    if col.kind_of?(Integer) and !(columns.include?(col))
      col = columns[col]
    end
    return @r['$'].call(@robj,col.to_s)[row]
  end

  def[]=(row,col,val)
    #How to set a value in this dataframe?
    @r.assign("rsrubytemp",@robj)
    
    ### VERY HACKY - This relies on val having the same
    #string representation in R and Ruby. An assign based
    #solution with proper conversion of val would be much 
    #better
    @r.eval_R("rsrubytemp[#{row+1},#{col+1}] <- #{val}")
    #
    #@r.assign("rsrubytemp[#{row+1},#{col+1}]",val)

    @robj = @r.eval_R('get("rsrubytemp")')

    return @r['$'].call(@robj,columns[col].to_s)[row]
  end

  def method_missing(attr)
    attr = attr.to_s
    mode = RSRuby.get_default_mode
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    column_names = @r.colnames(@robj)
    if attr == column_names or column_names.include?(attr)
      RSRuby.set_default_mode(mode)
      return @r['$'].call(@robj,attr.to_s)
    end

    #? Not sure what here...
    RSRuby.set_default_mode(mode)
    return super(attr)

  end

end
