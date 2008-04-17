require 'test/unit'
require 'rsruby'
         
class TestCleanup < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
  end

  def test_shutdown
    #@r.eval_R("shutdown_test=10")
    #@r.shutdown
    #assert_raise(RException){ @r.eval_R("shutdown_test") }
  end 
  
  def test_crash
    #Signal.trap('BUS','EXIT')
    #Signal.trap('BUS',proc{ puts 'hi there'; exit!})
    #@r.crash    
  end

end
