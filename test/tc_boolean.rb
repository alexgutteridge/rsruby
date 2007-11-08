require 'test/unit'
require 'rsruby'

class TestBoolean < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.c.autoconvert(RSRuby::BASIC_CONVERSION)
  end

  def test_true
    assert_block "r.TRUE not working" do 
      (@r.typeof(@r.FALSE) == 'logical' and 
       @r.as_logical(@r.TRUE))
    end
  end
  
  def test_false
    assert_block "r.FALSE not working" do
      (@r.typeof(@r.FALSE) == 'logical' and not
       @r.as_logical(@r.FALSE))
    end
  end

  def test_boolean_array
    assert_equal([true,false,true,false],@r.c(true,false,true,false))
  end

end
