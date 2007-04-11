require 'test/unit'
require 'rsruby'

class TestNewCases < Test::Unit::TestCase

  def test_erobj
    
    require 'rsruby/erobj'
    r = RSRuby.instance
    r.proc_table[lambda{|x| true}] = lambda{|x| ERObj.new(x)}
    RSRuby.set_default_mode(RSRuby::PROC_CONVERSION)

    f = r.c(1,2,3)
    assert_equal('[1] 1 2 3',f.to_s)
    assert_equal([1,2,3],f.to_ruby)
    assert_instance_of(RObj,f.as_r)

  end

  def test_dataframe

    require 'rsruby/dataframe'
    r = RSRuby.instance
    r.class_table['data.frame'] = lambda{|x| DataFrame.new(x)}
    RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)
    table = r.read_table("test/table.txt",:header=>true)
    assert_instance_of(DataFrame,table)
    
    assert_equal(['A','B','C','D'],table.columns)
    assert_equal(['1','2','3'],table.rows)

    #assert_equal(['X1','X2','X3'],table['A'])
    assert_equal('X2',table[1,'A'])
    assert_equal('X2',table[1,0])

    assert_equal(7,table[1,1])
    table[1,1] = 5
    assert_equal(5,table[1,1])

  end

end
