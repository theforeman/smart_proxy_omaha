require 'test_helper'
require 'smart_proxy_omaha/release'
require 'smart_proxy_omaha/release_provider'

class ReleaseProviderTest < Test::Unit::TestCase
  def setup
    @provider = Proxy::Omaha::ReleaseProvider.new(:track => :stable)
  end

  def test_releases
    stub_request(:get, 'https://stable.release.core-os.net/amd64-usr/').
      to_return(:status => [200, 'OK'], :body => fixture('stable.html'))

    expected = ['367.1.0',
                '410.0.0',
                '410.1.0',
                '410.2.0',
                '444.4.0',
                '444.5.0',
                '494.3.0',
                '494.4.0',
                '494.5.0',
                '522.4.0',
                '522.5.0',
                '522.6.0',
                '557.2.0',
                '607.0.0',
                '633.1.0',
                '647.0.0',
                '647.2.0',
                '681.0.0',
                '681.1.0',
                '681.2.0',
                '717.1.0',
                '717.3.0',
                '723.3.0',
                '766.3.0',
                '766.4.0',
                '766.5.0',
                '835.8.0',
                '835.9.0',
                '835.10.0',
                '835.11.0',
                '835.12.0',
                '835.13.0',
                '899.13.0',
                '899.15.0',
                '899.17.0',
                '1010.5.0',
                '1010.6.0',
                '1068.6.0',
                '1068.8.0',
                '1068.9.0',
                '1068.10.0',
                '1122.2.0']

    assert_equal expected.map {|v| Proxy::Omaha::Release.new(:track => @provider.track, :version => v) }, @provider.releases
  end
end
