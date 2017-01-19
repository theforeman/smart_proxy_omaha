require 'test_helper'
require 'json'
require 'smart_proxy_omaha/metadata_provider'

class MetadataProviderTest < Test::Unit::TestCase
  def setup
    @provider = Proxy::Omaha::MetadataProvider.new(:contentpath => '/tmp')
  end

  def test_get
    File.expects(:read).with('/tmp/stable/amd64-usr/1068.9.0/metadata.json').returns(stub_metadata.to_json)
    metadata = @provider.get('stable', '1068.9.0', 'amd64-usr')
    assert_kind_of Proxy::Omaha::Metadata, metadata
  end

  def test_store
    file_handle = mock('file')
    file_handle.expects(:write).with(stub_metadata.to_json)
    File.expects(:open).with('/tmp/stable/amd64-usr/1068.9.0/metadata.json', 'w').yields(file_handle).once
    metadata = Proxy::Omaha::Metadata.new(stub_metadata)
    assert @provider.store(metadata)
  end

  private

  def stub_metadata
    {
      :release => '1068.9.0',
      :architecture => 'amd64-usr',
      :sha1_b64 => 'foo',
      :sha256_b64 => 'bar',
      :size => '123',
      :track => 'stable'
    }
  end
end
