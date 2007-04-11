require 'test/unit'
require 'rsruby'

class TestLibrary < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
  end

  def test_library
    #Test success
    assert_nothing_raised(){@r.library("boot")}
  end

  def test_library_fail
    #Test failure
    assert_raises(RException){@r.library("Missing")}
  end  

end
