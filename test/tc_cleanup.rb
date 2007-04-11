require 'test/unit'
require 'rsruby'

class TestCleanup < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
  end

  def test_shutdown
    tempdir = @r.tempdir.call
    @r.postscript(tempdir+"/foo.ps")
    @r.plot(1,1)
    @r.dev_off.call
    assert(File.exists?(tempdir))
    @r.shutdown
    assert(!File.exists?(tempdir))
  end

end
