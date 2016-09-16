require 'test_helper'
require 'fileutils'
require 'tmpdir'
require 'smart_proxy_omaha/http_download'

class HttpDownloadTest < Test::Unit::TestCase

  def setup
    @source_url = 'http://example.com/omaha_downlod'
    @destination_dir = Dir.mktmpdir
    @destination_path = File.join(@destination_dir, 'test_file')
  end

  def teardown
    FileUtils.rm_rf(@destination_dir)
  end

  def test_downloads_file
    stub_request(:get, @source_url).to_return(:status => [200, 'OK'], :body => "body")

    http_download = ::Proxy::Omaha::HttpDownload.new(@source_url, @destination_path)
    task = http_download.start
    task.join
    assert_equal 'body', File.read(@destination_path)
    assert_equal true, http_download.result
  end

  def test_should_skip_download_if_one_is_in_progress
    locked = Proxy::FileLock.try_locking(@destination_path)
    http_download = ::Proxy::Omaha::HttpDownload.new(@source_url, locked.path)
    http_download.start.join
    assert_equal false, http_download.result
  end
end
