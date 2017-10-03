require 'test_helper'
require 'smart_proxy_omaha/omaha_protocol/request'

class RequestTest < Test::Unit::TestCase

  def setup
    Resolv.any_instance.stubs(:getname).returns('omaha.example.com')
    @request = Proxy::Omaha::OmahaProtocol::Request.new(
      xml_fixture('request_update_complete_update'),
      :ip => '1.1.1.1',
      :base_url => 'http://www.example.org/'
    )
  end

  def test_parses_request
    assert_equal 'e96281a6-d1af-4bde-9a0a-97b76e56dc57', @request.appid
    assert_equal '1068', @request.osmajor
    assert_equal '9.0', @request.osminor
    assert_equal 'stable', @request.track
    assert_equal 'amd64-usr', @request.board
    assert_equal '1010.5.0', @request.alephversion
    assert_equal '', @request.oemversion
    assert_equal '', @request.oem
    assert_equal 'CoreOS', @request.platform
    assert_equal 3, @request.eventtype
    assert_equal 2, @request.eventresult
    assert @request.updatecheck
    assert @request.ping
    assert_equal true, @request.ping?
    assert_equal true, @request.event?
    assert_equal true, @request.updatecheck?
  end

  def test_from_coreos
    assert @request.from_coreos?
  end

  def test_facts_data
    expected = {
      :facts => {
        :_timestamp => 'now',
        :_type => :foreman_omaha,
        :alephversion => '1010.5.0',
        :appid => 'e96281a6-d1af-4bde-9a0a-97b76e56dc57',
        :board => 'amd64-usr',
        :hostname => 'omaha.example.com',
        :ipaddress => '1.1.1.1',
        :ipaddress6 => nil,
        :oem => '',
        :oemversion => '',
        :osmajor => '1068',
        :osminor => '9.0',
        :platform => 'CoreOS',
        :track => 'stable',
        :version =>'1068.9.0'
      },
      :name => 'omaha.example.com'
    }
    received = @request.facts_data
    received[:facts][:_timestamp] = 'now'
    assert_equal expected, received
  end

  def test_to_status
    assert_equal :complete, @request.to_status
  end

  def test_parse_ipaddress
    assert_equal '1.1.1.1', @request.ipaddress
    assert_nil @request.ipaddress6

    request6 = Proxy::Omaha::OmahaProtocol::Request.new(
      xml_fixture('request_update_complete_update'),
      :ip => '2001:db8::1',
      :base_url => 'http://www.example.org/'
    )

    assert_nil request6.ipaddress
    assert_equal '2001:db8::1', request6.ipaddress6
  end
end
