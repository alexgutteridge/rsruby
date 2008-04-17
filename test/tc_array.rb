require 'test/unit'
require 'rsruby'

class TestArray < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    @r.gctorture(:on => false)
    @ruby_AoA = [[[0,6,12,18],[2,8,14,20],[4,10,16,22]],
                 [[1,7,13,19],[3,9,15,21],[5,11,17,23]]]

    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.array.autoconvert(RSRuby::NO_CONVERSION)
    @r_array  = @r.array({ :data => (0..24).to_a,
                           :dim  => [2,3,4]})
    @r.array.autoconvert(RSRuby::BASIC_CONVERSION)
  end

  def test_boolean
    assert_equal [true,false], @r.c(true,false)
  end

  def test_convert_to_ruby
    assert_equal(@ruby_AoA,@r_array.to_ruby)
  end

  #I suspect this only works in RPy with Numeric?
  def test_convert_to_R
    @r.list.autoconvert(RSRuby::NO_CONVERSION)
    @r['[['].autoconvert(RSRuby::NO_CONVERSION)
    o = @r['[['].call(@r.list(@ruby_AoA),1)
    @r['[['].autoconvert(RSRuby::BASIC_CONVERSION)
    #assert_equal(@r.all_equal(o,@r_array),true)
  end

  def test_dimensions
    assert_equal(@r.dim(@r_array),[@ruby_AoA.length,
                                   @ruby_AoA[0].length,
                                   @ruby_AoA[0][0].length])
  end

  def test_elements
    assert_equal(@ruby_AoA[0][0][0],@r['[['].call(@r_array, 1,1,1))
    assert_equal(@ruby_AoA[1][1][1],@r['[['].call(@r_array, 2,2,2))
  end

  def test_ruby_out_of_bounds
    assert_raise NoMethodError do
      @ruby_AoA[5][5][5]
    end
  end

  def test_R_out_of_bounds
    assert_raise RException do
      @r['[['].call(@r_array, 5,5,5)
    end
  end

end
