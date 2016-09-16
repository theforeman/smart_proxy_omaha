require 'test_helper'
require 'json'
require 'smart_proxy_omaha/metadata_provider'

class MetadataProviderTest < Test::Unit::TestCase
  def setup
    @provider = Proxy::Omaha::MetadataProvider.new(:contentpath => '/tmp')
  end

  def test_get
    File.expects(:read).with('/tmp/stable/1068.9.0/metadata.json').returns(stub_metadata.to_json)
    metadata = @provider.get('stable', '1068.9.0')
    assert_kind_of Proxy::Omaha::Metadata, metadata
  end

  def test_store
    File.expects(:write).with('/tmp/stable/1068.9.0/metadata.json', stub_metadata.to_json).returns(true)
    metadata = Proxy::Omaha::Metadata.new(stub_metadata)
    assert @provider.store(metadata)
  end

  private

  def stub_metadata
    {
      :release => '1068.9.0',
      :sha1_b64 => 'foo',
      :sha256_b64 => 'bar',
      :size => '123',
      :track => 'stable'
    }
  end
end
