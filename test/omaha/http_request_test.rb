require 'test_helper'
require 'smart_proxy_omaha/http_request'

class HttpDownloadTest < Test::Unit::TestCase
  def test_get
    request_url = 'http://www.example.com/file'
    stub_request(:get, request_url).to_return(:status => [200, 'OK'], :body => "body")

    result = ::Proxy::Omaha::HttpRequest.new.get(request_url)
    assert_equal 'body', result
  end
end
