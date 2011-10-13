require 'test/unit'
require 'rsruby'

class TestMem < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    RSRuby.set_default_mode(RSRuby::NO_DEFAULT)
    @r.class_table.clear
    @r.proc_table.clear
  end

  #test that robjects are not killed 
  def test_robjpersist
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)
    randarray = r.eval_R("x=runif(100,0,1)")
    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    vals = r.x
    r.eval_R("rm(x)")   
    RSRuby.set_default_mode(RSRuby::NO_CONVERSION)

    #do a bunch of stuff 
    10000.times do |n|
      a = RSRuby.instance.parse(:text =>"x#{n} = c(1:10000);")
      RSRuby.instance.eval(a)
      RSRuby.instance.eval_R("rm(x#{n})")
    end

    RSRuby.set_default_mode(RSRuby::BASIC_CONVERSION)
    assert_equal(vals, r.x)
    
  end

end

