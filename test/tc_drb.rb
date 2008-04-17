require 'test/unit'
require 'rsruby'
require 'client'

class TestDrb < Test::Unit::TestCase
  def setup
    @r = RSRuby.instance
  end
  
  def test_me
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
    assert_equal 2, @r.eval_R("1+1")
  end
  
  def test_me_some_more
    assert_equal 5, @r.eval_R("2+3")
  end
  
  def test_me_once_again
    assert_equal 4, @r.eval_R("2+2")
  end
end
