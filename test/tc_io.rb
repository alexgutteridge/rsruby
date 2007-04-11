require 'test/unit'
require 'rsruby'

class DummyIO
  def write
  end
end

class TestIO < Test::Unit::TestCase

  def setup
    @r = RSRuby.instance
    $stdout = $stderr = DummyIO.new
  end

  def teardown
    $stdout = STDOUT
    $stderr = STDERR
  end

  def test_io_stdin
    dummy = lambda{|prompt,n| prompt+'\n'}
    @r.set_rsruby_input(dummy)
    assert @r.readline('foo') == 'foo'
  end

  def test_io_stdout
    out = []
    dummy = lambda{|string| out.push(string)}
    @r.set_rsruby_output(dummy)
    @r.print(5)
    assert out == ['[1]','5','\n']
  end

  def test_io_showfiles
    out = []
    dummy = lambda{|files,headers,title,delete|
      out.push('foo')
    }
    @r.set_rsruby_showfiles(dummy)
    @r.help()
    assert out == ['foo']
  end
     
  def test_io_stdout_exception
    #TODO - I can't understand this test in Rpy
  end

  def test_io_stdin_exception
    #TODO - I can't understand this test in Rpy
  end  

  def test_io_stderr_exception
    #TODO - I can't understand this test in Rpy
  end

end
