require 'test_helper'
require 'fileutils'
require 'tmpdir'
require 'smart_proxy_omaha/release'

class ReleaseTest < Test::Unit::TestCase

  def setup
    @contentpath = Dir.mktmpdir
    Proxy::Omaha::Plugin.load_test_settings(
      {
        :contentpath => @contentpath
      }
    )
    @release = Proxy::Omaha::Release.new(
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '1068.9.0'
    )
  end

  def teardown
    FileUtils.rm_rf(@contentpath)
  end

  def test_path
    assert_equal "#{@contentpath}/stable/amd64-usr/1068.9.0", @release.path
  end

  def test_exists?
    assert_equal false, @release.exists?
    FileUtils.mkdir_p(@release.path)
    assert_equal true, @release.exists?
  end

  def test_create
    @release.expects(:create_path).once.returns(true)
    @release.expects(:download).once.returns(true)
    @release.expects(:create_metadata).once.returns(true)
    assert @release.create
  end

  def test_create_with_failure
    @release.expects(:create_path).once.returns(false)
    @release.expects(:download).never
    @release.expects(:create_metadata).never
    refute @release.create
  end

  def test_create_path
    assert @release.create_path
    assert File.directory?(@release.path)
  end

  def test_compare
    older = Proxy::Omaha::Release.new(
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '100.0.0'
    )
    newer = Proxy::Omaha::Release.new(
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '2000.0.0'
    )
    assert_equal 0, @release.<=>(@release)
    assert_equal -1, @release.<=>(newer)
    assert_equal 1, @release.<=>(older)
  end

  def test_equality
    other = Proxy::Omaha::Release.new(
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '100.0.0'
    )
    assert_equal @release, @release
    refute_equal other, @release
    refute_equal true, @release
  end

  def test_to_s
    assert_equal '1068.9.0', @release.to_s
  end

  def test_download
    stub_request(:get, /.*release\.core-os.*/).to_return(:status => [200, 'OK'], :body => "body")
    expected = [
      'coreos_production_pxe.vmlinuz',
      'coreos_production_pxe_image.cpio.gz',
      'coreos_production_image.bin.bz2',
      'coreos_production_image.bin.bz2.sig',
      'update.gz'
    ]

    assert_equal true, @release.create_path
    assert_equal true, @release.download

    existing_files = Dir.entries(@release.path) - ['.', '..']

    assert_equal expected.sort, existing_files.sort
  end

  def test_create_metadata
    file = File.join(@release.path, 'metadata.json')

    digest = mock()
    digest.expects(:base64digest).twice.returns('foo')
    File.expects(:size).once.returns(0)
    Digest::SHA1.expects(:file).once.returns(digest)
    Digest::SHA256.expects(:file).once.returns(digest)

    expected = '{"release":"1068.9.0","architecture":"amd64-usr","sha1_b64":"foo","sha256_b64":"foo","size":0,"track":"stable"}'

    assert_equal true, @release.create_path
    assert_equal true, @release.create_metadata
    assert File.exist?(file)
    assert_equal JSON.parse(expected), JSON.parse(File.read(file))
  end
end
