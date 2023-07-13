# frozen_string_literal: true

require 'test_helper'
require 'smart_proxy_omaha/release'
require 'smart_proxy_omaha/release_provider'
require 'smart_proxy_omaha/distribution'

class ReleaseProviderTest < Test::Unit::TestCase
  def test_releases_coreos
    distribution = ::Proxy::Omaha::Distribution::Coreos.new
    provider = Proxy::Omaha::ReleaseProvider.new(
      distribution: distribution,
      track: :stable,
      architecture: 'amd64-usr'
    )

    stub_request(:get, 'https://stable.release.core-os.net/amd64-usr/')
      .to_return(status: [200, 'OK'], body: fixture('stable.html'))

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

    assert_equal expected.map { |v|
                   Proxy::Omaha::Release.new(distribution: distribution, track: provider.track, version: v, architecture: 'amd64-usr')
                 }, provider.releases
  end

  def test_releases_flatcar
    distribution = ::Proxy::Omaha::Distribution::Flatcar.new
    provider = Proxy::Omaha::ReleaseProvider.new(
      track: :stable,
      architecture: 'amd64-usr',
      distribution: distribution
    )

    stub_request(:get, 'https://www.flatcar.org/releases-json/releases-stable.json')
      .to_return(status: [200, 'OK'], body: fixture('flatcar_releases-stable.json'))

    expected = ['1688.5.3', '1745.3.1', '1745.4.0', '1745.5.0', '1745.6.0', '1745.7.0', '1800.4.0', '1800.5.0',
                '1800.6.0', '1800.7.0', '1855.4.0', '1855.4.2', '1855.5.0', '1911.3.0', '1911.4.0', '1911.5.0', '1967.3.0', '1967.3.1', '1967.4.0', '1967.5.0', '1967.6.0', '2023.4.0', '2023.5.0', '2079.3.0', '2079.3.1', '2079.3.2', '2079.4.0', '2079.5.0', '2079.6.0', '2135.4.0', '2135.5.0', '2135.6.0', '2191.4.0', '2191.4.1', '2191.5.0', '2247.5.0', '2247.6.0', '2247.7.0', '2303.3.0', '2303.3.1', '2303.4.0', '2345.3.0']

    assert_equal expected.map { |v|
                   Proxy::Omaha::Release.new(distribution: distribution, track: provider.track, version: v, architecture: 'amd64-usr')
                 }, provider.releases
  end
end
