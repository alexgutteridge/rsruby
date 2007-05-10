require 'test/unit'
require 'rsruby'

class TestInit < Test::Unit::TestCase

  def test_init
    assert_nothing_raised(){RSRuby.instance}
    assert_instance_of(RSRuby, RSRuby.instance)
    assert_equal(RSRuby.instance, RSRuby.instance)
  end
end
