require 'test/unit'
require 'rsruby'

class TestSigint < Test::Unit::TestCase

  def test_sigint
    assert_raises(KeyboardInterrupt){Process.kill('SIGINT',0)}
  end

end
