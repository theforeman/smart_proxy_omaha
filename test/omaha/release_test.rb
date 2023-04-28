require 'test_helper'
require 'fileutils'
require 'tmpdir'
require 'smart_proxy_omaha/release'
require 'smart_proxy_omaha/distribution'

class ReleaseTest < Test::Unit::TestCase

  def setup
    @contentpath = Dir.mktmpdir
    Proxy::Omaha::Plugin.load_test_settings(
      {
        :contentpath => @contentpath,
      }
    )
    @release = Proxy::Omaha::Release.new(
      :distribution => ::Proxy::Omaha::Distribution::Coreos.new,
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '1068.9.0'
    )
  end

  def teardown
    FileUtils.rm_rf(@contentpath)
  end

  def test_paths
    assert_equal "#{@contentpath}/stable/amd64-usr", @release.base_path
    assert_equal "#{@contentpath}/stable/amd64-usr/1068.9.0", @release.path
    assert_equal "#{@contentpath}/stable/amd64-usr/current", @release.current_path
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
      :distribution => ::Proxy::Omaha::Distribution::Coreos.new,
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '100.0.0'
    )
    newer = Proxy::Omaha::Release.new(
      :distribution => ::Proxy::Omaha::Distribution::Coreos.new,
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
      :distribution => ::Proxy::Omaha::Distribution::Coreos.new,
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
    stub_request(:get, /.*release\.core-os.*/).to_return(
      :status => [200, 'OK'],
      :body => 'body',
      headers: {
        'Content-Length' => 4,
        'x-goog-hash' => 'md5=hBotaJrYa9FhFEdFPCLG/A==',
      }
    )

    assert_equal true, @release.create_path
    assert_equal true, @release.download

    existing_files = Dir.entries(@release.path) - ['.', '..']

    assert_equal (expected_release_files + ['update.gz.DIGESTS']).sort, existing_files.sort
    assert_equal "841a2d689ad86bd1611447453c22c6fc  update.gz\n", File.read(File.join(@release.path, 'update.gz.DIGESTS'))
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

  def test_missing_existing_files
    FileUtils.mkdir_p(@release.path)
    refute @release.complete?
    assert_empty @release.existing_files
    assert_equal expected_release_files.sort, @release.missing_files.sort

    expected_release_files.each do |file|
      FileUtils.touch(File.join(@release.path, file))
    end

    assert @release.complete?
    assert_empty @release.missing_files
    assert_equal expected_release_files.sort, @release.existing_files.sort
  end

  def test_current_release_idempotent
    FileUtils.mkdir_p(@release.path)
    refute @release.current?
    @release.mark_as_current!
    assert @release.current?
    symlinks = Dir.glob("#{@contentpath}/**/*").select { |f| File.symlink?(f) }
    assert_equal 1, symlinks.count
    @release.mark_as_current!
    assert @release.current?
    assert_equal symlinks, Dir.glob("#{@contentpath}/**/*").select { |f| File.symlink?(f) }
    assert_equal @release.path, File.readlink(@release.current_path)
  end

  def test_current_release_update
    FileUtils.mkdir_p(@release.path)
    older = Proxy::Omaha::Release.new(
      :distribution => ::Proxy::Omaha::Distribution::Coreos.new,
      :track => :stable,
      :architecture => 'amd64-usr',
      :version => '100.0.0'
    )
    FileUtils.mkdir_p(older.path)
    older.mark_as_current!
    assert older.current?
    refute @release.current?
    @release.mark_as_current!
    assert @release.current?
    refute older.current?
  end

  def test_digests_valid
    FileUtils.mkdir_p(@release.path)
    File.open(File.join(@release.path, "update.gz"), 'w') { |file| file.write('body') }
    File.open(File.join(@release.path, "update.gz.DIGESTS"), 'w') { |file| file.write("841a2d689ad86bd1611447453c22c6fc  update.gz\n") }
    expected = {
      'update.gz' => ['841a2d689ad86bd1611447453c22c6fc'],
    }
    assert_equal expected, @release.digests
    assert_equal true, @release.valid?
  end

  def test_digests_invalid
    FileUtils.mkdir_p(@release.path)
    File.open(File.join(@release.path, "update.gz"), 'w') { |file| file.write('invalid') }
    File.open(File.join(@release.path, "update.gz.DIGESTS"), 'w') { |file| file.write("841a2d689ad86bd1611447453c22c6fc  update.gz\n") }
    assert_equal false, @release.valid?
  end

  private

  def expected_release_files
    [
      'coreos_production_pxe.vmlinuz',
      'coreos_production_pxe.DIGESTS',
      'coreos_production_pxe_image.cpio.gz',
      'coreos_production_pxe_image.cpio.gz.DIGESTS',
      'coreos_production_image.bin.bz2',
      'coreos_production_image.bin.bz2.sig',
      'coreos_production_image.bin.bz2.DIGESTS',
      'coreos_production_vmware_raw_image.bin.bz2',
      'coreos_production_vmware_raw_image.bin.bz2.sig',
      'coreos_production_vmware_raw_image.bin.bz2.DIGESTS',
      'update.gz',
      'version.txt',
      'version.txt.DIGESTS',
    ]
  end
end
