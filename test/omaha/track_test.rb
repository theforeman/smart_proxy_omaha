require 'test_helper'
require 'smart_proxy_omaha/track'

class TrackTest < Test::Unit::TestCase

  def test_valid
    assert_equal true, Proxy::Omaha::Track.valid?('alpha')
  end

  def test_invalid
    assert_equal false, Proxy::Omaha::Track.valid?('bär')
  end
end
