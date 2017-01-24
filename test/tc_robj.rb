require 'test/unit'
require 'rsruby'

class TestRObj < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.class_table.clear
    @r.proc_table.clear
  end

  def test_type
    assert_equal(@r.array.class, RObj)
  end

  def test_call
    #TODO
  end

  def test_keyword_parameters
    #TODO - In RPy keyword parameters are converted like the method calls
    #In ruby this isn't such a problem because you can use quoted strings
    #but we will implement it anyway.
    @r.list.autoconvert(RSRuby::BASIC_CONVERSION)
    d = @r.list(:foo => 'foo', :bar_foo => 'bar.foo', :print_ => 'print', :as_data_frame => 'as.data.frame')
    d.each do |k,v|
      assert_equal(k, d[k])
    end
  end

  def test_bad_keyword_parameters
    #TODO?
    #assert_raises(ArgumentError){@r.list(:none => 1)}
  end

  def test_name_conversions
    assert_equal(@r.array, @r['array'])
    assert_equal(@r.print_,@r['print'])
    assert_equal(@r.as_data_frame, @r['as.data.frame'])
    assert_equal(@r.attr__, @r['attr<-'])
  end

  def test_not_found
    assert_raises(RException){@r.foo}
  end

  def test_name_length_one
    assert_nothing_raised{@r.T}
  end

  def test_autoconvert
    @r.seq.autoconvert(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.seq(10), (1..10).to_a)
    @r.seq.autoconvert(RSRuby::NO_CONVERSION)
    assert_equal(@r.seq(10).class, RObj)
  end

  def test_bad_autoconvert
    assert_raises(ArgumentError){@r.seq.autoconvert(RSRuby::TOP_CONVERSION+1)}
  end

  def test_get_autoconvert
    @r.seq.autoconvert(RSRuby::BASIC_CONVERSION)
    mode = @r.seq.autoconvert
    assert_equal(mode, RSRuby::BASIC_CONVERSION)
  end

  def test_r_gc
    #TODO - How can this work?
    @r.seq.autoconvert(RSRuby::NO_CONVERSION)
    arr = @r.seq(100000)
    @r.gc
    assert(@r['['].call(arr,10))
  end

  def test_lcall
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    arr = @r.c.lcall([['',0],['a',1],['b',2],['c',3]])
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.names(arr), ['','a','b','c'])
  end
  def test_initialize
    robj = RObj.new([1,2,3])
    assert_equal('RObj',robj.class)
  end
end
