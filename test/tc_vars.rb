require 'test/unit'
require 'rsruby'

class TestVars < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
  end

  def test_get_vars
    @r.eval_R("f<-function(x) x+1")
    @r.assign('x',100)
    @r.assign('v',(1..10).to_a)
    #There is a difference here between RPy and us
    #a final hash argument is treated as named arguments
    #to the original function call (assign) not as a list
    #to be given to the function
    @r.c.autoconvert(RSRuby::NO_CONVERSION)
    @r.assign('d',@r.c({'a' => 1, 'b' => 2}))
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)

    assert_equal(@r.x, 100)
    assert_equal(@r.v, (1..10).to_a)
    assert_equal(@r.d, @r.c({'a' => 1, 'b' => 2}))
    assert_equal(@r.f.class, @r.c.class)
  end

end
