require 'test/unit'
require 'rsruby'

class TestEval < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    @r.proc_table = {}
    @r.class_table = {}
  end

  def test_eval_R
    #Test integer, Float, String and Boolean return values
    assert_equal(@r.eval_R("sum(1,2,3)"),6)
    assert_equal(@r.eval_R("sum(1.5,2.5,3.5)"),7.5)
    assert_equal(@r.eval_R("eval('R')"),"R")
    assert_equal(@r.eval_R("is(1,'numeric')"),true)
    assert_equal(@r.eval_R("is(1,'madeup')"),false)  
  end

end
