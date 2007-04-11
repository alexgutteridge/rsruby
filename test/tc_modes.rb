require 'test/unit'
require 'rsruby'

class TestModes < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.class_table.clear
    @r.proc_table.clear
  end

  def test_to_ruby_args
    assert_raises(ArgumentError){@r.seq.to_ruby(RSRuby::TOP_CONVERSION+1)}
    assert_raises(ArgumentError){@r.seq.to_ruby(-2)}
    assert_raises(TypeError){@r.seq.to_ruby('foo')}
  end

  def test_to_ruby
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    four = @r.c(4)
    assert_equal(four.to_ruby, 4)
    assert_equal(four.to_ruby(RSRuby::PROC_CONVERSION), 4)
    assert_equal(four.to_ruby(RSRuby::BASIC_CONVERSION), 4)
    assert_equal(four.to_ruby(RSRuby::VECTOR_CONVERSION), [4])
    assert(@r["=="].call(four.to_ruby(RSRuby::NO_CONVERSION),four))
  end

  def test_to_ruby_default_arg
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    sequence = @r.seq(1,3)
    t_test   = @r.t_test([1,2,3])

    assert_equal(sequence.to_ruby.class , RObj)
    assert_equal(sequence.to_ruby.class, sequence.class)

    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(sequence.to_ruby, [1,2,3])
    
    RSRuby.set_default_mode(RSRuby::VECTOR_CONVERSION)
    assert_equal(sequence.to_ruby, [1,2,3])

    @r.class_table['htest'] = lambda{5}
    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    assert_equal(t_test.to_ruby, 5)

    @r.proc_table[lambda{true}] = lambda{return 6}
    RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)
    assert_equal(t_test.to_ruby, 6)
  end

  def test_default_modes
    RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)
    assert_equal(RSRuby.get_default_mode, RSRuby::PROC_CONVERSION)
    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    assert_equal(RSRuby.get_default_mode, RSRuby::CLASS_CONVERSION)
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(RSRuby.get_default_mode, RSRuby::BASIC_CONVERSION)
    RSRuby.set_default_mode(RSRuby::VECTOR_CONVERSION)
    assert_equal(RSRuby.get_default_mode, RSRuby::VECTOR_CONVERSION)
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    assert_equal(RSRuby.get_default_mode, RSRuby::NO_CONVERSION)
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    assert_equal(RSRuby.get_default_mode, RSRuby::NO_DEFAULT)
  end

  def test_bad_modes
    assert_raises(ArgumentError){RSRuby.set_default_mode(-2)}
    assert_raises(ArgumentError){RSRuby.set_default_mode(RSRuby::TOP_CONVERSION+1)}
  end

  def test_no_default_mode
    @r.t_test.autoconvert(RSRuby::CLASS_CONVERSION)
    @r.array.autoconvert(RSRuby::NO_CONVERSION)
    @r.seq.autoconvert(RSRuby::BASIC_CONVERSION)

    assert_equal(@r.array(1,3).class, @r.array.class)
    
    assert_equal(@r.seq(1,3), [1,2,3])
    @r.class_table['htest'] = lambda{5}
    assert_equal(@r.t_test([1,2,3]), 5)
  end

  def test_individual_conversions
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
    @r.seq.autoconvert(RSRuby::PROC_CONVERSION)
    @r.min.autoconvert(RSRuby::VECTOR_CONVERSION)

    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    assert_equal(@r.c(4).class, RObj)
    assert_equal(@r.seq(1,3).class, RObj)
    assert_equal(@r.min(1,3).class, RObj)

    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    assert_equal(@r.c.autoconvert, RSRuby::BASIC_CONVERSION)
    assert_equal(@r.seq.autoconvert, RSRuby::PROC_CONVERSION)
    assert_equal(@r.min.autoconvert, RSRuby::VECTOR_CONVERSION)
    assert_equal(@r.c(4), 4)
    assert_equal(@r.seq(1,3), [1,2,3])
    assert_equal(@r.min(1,3), [1])
    
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.c.autoconvert, RSRuby::BASIC_CONVERSION)
    assert_equal(@r.seq.autoconvert, RSRuby::PROC_CONVERSION)
    assert_equal(@r.min.autoconvert, RSRuby::VECTOR_CONVERSION)
    assert_equal(@r.c(4), 4)
    assert_equal(@r.seq(1,3), [1,2,3])
    assert_equal(@r.min(1,3), 1)

    RSRuby.set_default_mode(RSRuby::VECTOR_CONVERSION)
    assert_equal(@r.c.autoconvert, RSRuby::BASIC_CONVERSION)
    assert_equal(@r.seq.autoconvert, RSRuby::PROC_CONVERSION)
    assert_equal(@r.min.autoconvert, RSRuby::VECTOR_CONVERSION)
    assert_equal(@r.c(4), [4])
    assert_equal(@r.seq(1,3), [1,2,3])
    assert_equal(@r.min(1,3), [1])

  end

  def test_vector_conversion
    
    RSRuby.set_default_mode(RSRuby::VECTOR_CONVERSION)

    assert_equal(@r.c(true), [true])
    assert_equal(@r.c(4)   , [4])
    assert_equal(@r.c('A') , ['A'])

    assert_equal(@r.c(1,'A',2), ['1','A','2'])
    assert_equal(@r.c(:a => 1, :b => 'A', :c => 2), {'a' => '1', 'b' => 'A', 'c' => '2'})
    assert_equal(@r.list(:a => 1, :b => 'A', :c => 2), 
      {'a' => [1], 'b' => ['A'], 'c' => [2]})
    assert_equal(@r.eval_R("x~y").class, RObj)
  end

  def test_basic_conversion

    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(@r.c(true), true)
    assert_equal(@r.c(4), 4)
    assert_equal(@r.c('A') , 'A')

    assert_equal(@r.c(1,'A',2), ['1','A','2'])
    assert_equal(@r.c(:a => 1, :b => 'A', :c => 2), {'a' => '1', 'b' => 'A', 'c' => '2'})
    assert_equal(@r.list(:a => 1, :b => 'A', :c => 2), 
      {'a' => 1, 'b' => 'A', 'c' => 2})
    assert_equal(@r.eval_R("x~y").class, RObj)
    
  end

  def test_class_table

    @r.class_table['htest'] = lambda{'htest'}
    @r.class_table['data.frame'] = lambda{|x| 
      if @r['[['].call(x,1).length > 2
        return 5
      else
        return 'bar'
      end
    }
    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    assert_equal(@r.t_test([1,2,3]), 'htest')
    assert_equal(@r.as_data_frame([1,2,3]), 5)
    assert_equal(@r.as_data_frame([1,2]), 'bar')

  end

  def test_multiple_class_table

    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    f = @r.class__(@r.c(4),'foo')
    g = @r.class__(@r.c(4), ['bar','foo'])

    @r.class_table['foo'] = lambda{'foo'}
    @r.class_table['bar'] = lambda{'bar'}
    @r.class_table[['bar','foo']] = lambda{5}

    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    assert_equal(f.to_ruby, 'foo')
    assert_equal(g.to_ruby, 5)

    @r.class_table.delete(['bar','foo'])
    assert_equal(g.to_ruby, 'bar')
    
    @r.class_table.delete('bar')
    assert_equal(g.to_ruby, 'foo')
    
  end

  def test_proc_table

    t = lambda{|x|
      e = @r.attr(x,'names')
      return false if e.nil?
      if e == 'alternative' or e.include?('alternative')
        return true
      else
        return false
      end
    }
    f = lambda{|x| @r['$'].call(x,'alternative')}

    @r.proc_table[t] = f
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.t_test.autoconvert(RSRuby::PROC_CONVERSION)
    assert_equal(@r.t_test([1,2,3]), 'two.sided')

  end

  def test_proc_convert

    r = RSRuby.instance

    check_str = lambda{|x| RSRuby.instance.is_character(x)}
    f = lambda{|x|
      x = x.to_ruby(RSRuby::BASIC_CONVERSION)
      return "Cannot return 'foo'" if x == 'foo'
      return x
    }
    
    r.proc_table[check_str] = f

    RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)

    assert_equal('bar',r.c('bar'))
    assert_equal("Cannot return 'foo'",r.c('foo'))
    assert_equal(['bar','foo'],r.c('bar','foo'))

  end

  def test_restore_mode_after_exception_in_proc

    r = RSRuby.instance
    
    check_str = lambda{|x| RSRuby.instance.is_character(x)}
    f = lambda{|x|
      x.reverse
    }
    
    r.proc_table[check_str] = f

    RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)

    assert_equal(6,r.sum(1,2,3))
    assert_equal(RSRuby::PROC_CONVERSION,RSRuby.get_default_mode)
    assert_raise(NoMethodError){r.paste("foo","bar")}
    assert_raise(NoMethodError){r.paste("foo","bar")}
    assert_equal(RSRuby::PROC_CONVERSION,RSRuby.get_default_mode)

  end

  def test_restore_mode_after_exception_in_class

    r = RSRuby.instance
    r.class_table['htest'] = lambda{|x| x.foo}

    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    assert_equal(RSRuby::CLASS_CONVERSION,RSRuby.get_default_mode)
    assert_raise(NoMethodError){r.t_test([1,2,3])}
    assert_raise(NoMethodError){r.t_test([1,2,3])}
    assert_equal(RSRuby::CLASS_CONVERSION,RSRuby.get_default_mode)

  end

end
