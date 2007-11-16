require 'test/unit'
require 'rsruby'

class TestToRuby < Test::Unit::TestCase
  @@test_dir = File.expand_path File.dirname(__FILE__) 
  
  def setup
    @r = RSRuby.instance
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.seq.autoconvert(RSRuby::BASIC_CONVERSION)
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
  end

  def test_null_to_nil
    assert(@r.attributes(@r.seq).nil?)
  end

  def test_factor_to_list
    assert_equal(@r.factor([1,2,3,4]), ['1','2','3','4'])
    assert_equal(@r.factor([1,1,1,2]), ['1','1','1','2'])
    assert_equal(@r.factor(['a','b','c']), ['a','b','c'])
  end

  def test_NA_int
    #The formula on right should equal smallest Fixnum
    #in current Ruby build (can vary)
    assert_equal(@r.NA, (-1)*(2**((1.size*8)-1)))
    assert(@r.is_na(@r.NA))
  end

  def test_NA_string
    assert_equal(@r.eval_R('as.character(NA)'), 'NA')
    assert_equal(@r.as_character(@r.NA), 'NA')
    assert_equal(@r.as_character(@r.NaN), 'NaN')
  end

  def test_factor_NA
    assert_equal(@r.factor(@r.NA) , 'NA')
    assert_equal(@r.factor(@r.NaN), 'NaN')
    assert_equal(@r.factor(@r.as_character('NA')), 'NA')

    xi = [1,2,@r.NA,@r.NaN,4]
    assert_equal(@r.factor(xi), ['1','2','NA','NaN','4'])

    xd = [1.01,2.02,@r.NA,@r.NaN,4.04]
    assert_equal(@r.factor(xd), ['1.01','2.02','NA','NaN','4.04'])

  end

  def test_NA_list

    #TODO - RPy has commented out these tests as well. 
    #The conversion between NA/NaN and Ruby seems a little confused 
    #at the moment

    xi = [1,2,@r.NA,@r.NaN,4]
    assert_equal(@r.as_character(xi), ['1','2','NA','NaN','4'])
    #assert_equal(@r.as_numeric(xi)  , [1.0,2.0,@r.NA,@r.NaN,4.0])
    #assert_equal(@r.as_integer(xi)  , [1,2,@r.NA,@r.NaN,4])
    assert_equal(@r.factor(xi)      , ['1','2','NA','NaN','4'])
    assert_equal(@r.is_na(xi)       , [false, false, true, true, false])

    xd = [1.01,2.02,@r.NA,@r.NaN,4.04]
    assert_equal(@r.as_character(xd), ['1.01','2.02','NA','NaN','4.04'])
    #assert_equal(@r.as_numeric(xi)  , [1.01,2.01,@r.NA,@r.NaN,4.01])
    assert_equal(@r.as_integer(xd)  , [1,2,@r.NA,@r.NA,4])
    assert_equal(@r.factor(xd)      , ['1.01','2.02','NA','NaN','4.04'])
    assert_equal(@r.is_na(xd)       , [false, false, true, true, false])    
  end

  #TODO - table.txt?????????
  def test_dataframe_to_list
    @r.read_table.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.read_table(@@test_dir+"/table.txt", {:header => 1}), 
      {
        'A' => ['X1','X2','X3'], 
        'C' => [5,8,2], 
        'B' => [4.0,7.0,6.0],
        'D' => ['6','9','Foo']
      })
  end
  
  def test_logical_to_boolean
    assert_equal(@r.TRUE,  true)
    assert_equal(@r.T,     true)
    assert_equal(@r.FALSE, false)
    assert_equal(@r.F,     false)
  end

  def test_int_to_int
    assert_equal(@r.as_integer(5),5)
    assert_equal(@r.as_integer(-3),-3)
  end

  def test_float_to_float
    assert_equal(@r.as_real(5),5.0)
    assert_equal(@r.as_real(3.1),3.1)
    assert_equal(@r.as_real(-3.1), -3.1)
  end

  def test_complex_to_complex
    #TODO - Think about Complex support
    assert_equal(@r.as_complex(Complex(1,2)), Complex(1,2))
    assert_equal(@r.as_complex(Complex(1.5,-3.4)), Complex(1.5,-3.4))
  end

  def test_str_to_str
    @r.as_data_frame.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.class_(@r.as_data_frame([1,2,3])), 'data.frame')
  end

  def test_vector_length_one
    assert_equal(@r.c(1),1)
    assert_equal(@r.c('foo'),'foo')
  end

  def test_int_vector_to_array
    assert_equal(@r.seq(10),[1,2,3,4,5,6,7,8,9,10])
  end

  def test_float_vector_to_array
    assert_equal(@r.seq(1,2,{:by => 0.5}), [1.0,1.5,2.0])
  end

  def test_complex_vector_to_array
    assert_equal(@r.c(Complex(1,2),Complex(2,-3)),[Complex(1,2),Complex(2,-3)])
  end

  def test_str_vector_to_array
    assert_equal(@r.c('Foo','Bar'),['Foo','Bar'])
  end

  def test_list_to_array
    @r.list.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.list(1,2.0,'foo'),[1,2.0,'foo'])
  end

  def test_named_vector_to_hash
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    a = @r.attr__(@r.c(1,2,3), 'names', ['foo','bar','baz'])
    assert_equal(a,{'foo'=>1,'bar'=>2,'baz'=>3})
    assert_equal(@r.list(:foo => 1, :bar => 2, :baz => 3),{'foo'=>1,'bar'=>2,'baz'=>3})
  end

  def test_vector_coercion
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.typeof(@r.c(1,2,3)), 'integer')
    assert_equal(@r.typeof(@r.c(1,2.0,3)), 'double')
    assert_equal(@r.typeof(@r.c(1,Complex(2,3),3)), 'complex')
    assert_equal(@r.typeof(@r.c(1,'foo',3)), 'character')    
  end

end
