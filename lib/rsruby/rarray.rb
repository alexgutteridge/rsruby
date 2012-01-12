require 'rsruby'
class RArray
  attr_reader :array
  def initialize(_array,_dimnames,_dimnamesorder)
    @array = _array
    @dimnames = _dimnames
    @dimnamesorder = _dimnamesorder
  end
#  def method_missing(m,*args)
#    if args.length>0
#      @array.send(m,args)
#    else
#      @array.send(m)
#    end
#  end
  def [](index)
    @array[index]
  end
  # trim the innermost dimension to n
  # innermost dimension is outermost dimension in R
  def trim(_n)
  end
  #we must handle either array or hash of dim names
  #since we don't know what rsruby is going to give
  def dimension_count
    @dimnames.length
  end
  def subset(_keys,_dim)
    all_keys = dimnames_along_dimension(_dim)
    new_order = _keys.map{|x|
      all_keys.index(x)
    }
    new_order=new_order.compact
    new_array = subset_helper(@array,new_order,0,_dim)
    if @dimnames.is_a? Array
      new_dimnames = @dimnames.dup
      new_dimnames[_dim] = _keys
      RArray.new(new_array,new_dimnames,nil)
    else #hash
      new_dimnames = @dimnames.merge({@dimnamesorder[_dim] => _keys})
      RArray.new(new_array,new_dimnames,@dimnamesorder.dup)
    end
  end
  def subset_helper(_array,_new_order,_current_depth,_target_depth)
    if _current_depth == _target_depth
      _new_order.map{|x|
        _array.fetch(x)
      }
    else
      _array.map{|x|
        subset_helper(x,_new_order,_current_depth+1,_target_depth) 
      }
    end
  end
  def get(*_args)
    indices = _args.each_with_index.map{|x,i|
      d = dimnames_along_dimension(i)
      j= d.index(x)
      return nil unless j
      j
    }
    a=@array
    indices.each{|i|
      a=a[i]
    }
    a
  end
#  def first(_n)
#    new_array = @array.first(_n)
#    new_dimnames = nil
#    if @dimnames.is_a? Array
#      new_dimnames = dimnames.dup
#      new_dimnames[0] = new_dimnames[0].first(_n)
#    else #hash
#      new_dimnames = @dimnames.merge ({@dimnamesorder[0] => dimnames(0).first(_n)})
#    end
#    RArray.new(new_array,new_dimnames,@dimnamesorder)
#  end


  def dimnames_along_dimension(_index)
    return @dimnames[_index] if @dimnames.is_a? Array
    return @dimnames[@dimnamesorder[_index]] if @dimnames.is_a? Hash
    raise "unsupported dimnames"
  end
  def dimension_names
    return @dimnamesorder
  end
end
