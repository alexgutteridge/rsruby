require 'test/unit'
require 'rsruby'

class Matrix
  def as_r
    "wibble"
  end
end

class TestMatrix < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
  end

  def test_matrix_no_convert
    r = RSRuby.instance
    r.matrix.autoconvert(RSRuby::NO_CONVERSION)
    m = r.matrix([1,2,3,4], :ncol => 2, :nrow => 2)
    assert r.is_matrix(m)
    assert false
  end
end
