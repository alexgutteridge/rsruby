require 'test/unit'
require 'rsruby'

class Foo
end

class Bar
  def initialize(x)
    @x = x
  end
  def as_r
    @x
  end
end

class TestToR < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    #@r.gctorture(:on => true)
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
  end

  def test_robj_to_r

    @r.c.autoconvert(RSRuby::NO_CONVERSION)

    r1 = @r.c(4)
    r2 = @r.c('foo')
    r3 = @r.c(['a','b'])

    assert(@r['=='].call(r1,4))
    assert(@r['=='].call(r2,'foo'))
    assert(@r['=='].call(r3,['a','b']))

    assert_equal(@r.typeof(@r.eval),'closure')
    assert_equal(@r.typeof(@r.eval(@r.eval)), 'closure')
    assert_equal(@r.typeof(@r.eval([@r.eval,@r.eval])), 'list')

    #Same tests as above in basic mode - should be identical
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)

    r1 = @r.c(4)
    r2 = @r.c('foo')
    r3 = @r.c(['a','b'])

    assert(@r['=='].call(r1,4))
    assert(@r['=='].call(r2,'foo'))
    assert(@r['=='].call(r3,['a','b']))

    assert_equal(@r.typeof(@r.eval),'closure')
    assert_equal(@r.typeof(@r.eval(@r.eval)), 'closure')
    assert_equal(@r.typeof(@r.eval([@r.eval,@r.eval])), 'list')

  end

  def test_empty_array_to_null
    assert(@r.is_null([]))
  end

  def test_boolean_to_logical
    assert_equal(@r.c(true),true)
    assert_equal(@r.c(true).class,true.class)
    assert_equal(@r.c(false),false)
    assert_equal(@r.c(false).class,false.class)
  end

  def test_int_to_int
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.typeof(@r.c(4)), 'integer')
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.typeof(@r.c(4)), 'integer')
  end

  def test_float_to_float
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.typeof(@r.c(4.5)), 'double')
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.typeof(@r.c(4.5)), 'double')
  end

  def test_char_to_char
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.typeof(@r.c('foo')), 'character')
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.typeof(@r.c('foo')), 'character')
  end

  def test_hash_to_named_vector
    @r.c.autoconvert(RSRuby::NO_CONVERSION)    
    assert_equal(@r.typeof(@r.c(:foo => 5, :bar => 7)),'integer')
    
    assert(@r.attributes(@r.c(:foo => 5, :bar => 7))['names'].include?('foo'))
    assert(@r.attributes(@r.c(:foo => 5, :bar => 7))['names'].include?('bar'))
    #TODO - these fail because of the different calling semantics in
    #RSRuby
    #@r.c.autoconvert(RSRuby::BASIC_CONVERSION)    
    #assert_equal(@r.typeof(@r.c(:foo => 5, :bar => 7)),'integer')
    #assert(@r.attributes(@r.c(:foo => 5, :bar => 7))['names'].include?('foo'))
    #assert(@r.attributes(@r.c(:foo => 5, :bar => 7))['names'].include?('bar'))      
  end

  def test_array_to_vector
    @r.c.autoconvert(RSRuby::NO_CONVERSION)    
    assert_equal(@r.length(@r.c(1,2,3,4)),4)
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)    
    assert_equal(@r.length(@r.c(1,2,3,4)),4)
  end

  def test_not_convertible
    #TODO - range?
    assert_raises(ArgumentError){@r.c(1..10)}
  end

  def test_instances_not_convertible
    foo = Foo.new
    assert_raises(ArgumentError){@r.c(foo)}
   end

  def test_as_r_method
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)

    a = Bar.new(3)
    b = Bar.new('foo')
    d = Bar.new(@r.seq)

    assert_equal(@r.c(a),3)
    assert_equal(@r.c(b),'foo')
    assert_equal(@r.c(d).call(1,3),[1,2,3])

  end

  def test_max_int_to_r
    #TODO
  end

  def test_inf_to_r
    #TODO
  end

  def test_NaN_to_r
    #TODO
  end

end
