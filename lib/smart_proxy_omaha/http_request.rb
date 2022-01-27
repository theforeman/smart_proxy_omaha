require 'smart_proxy_omaha/http_shared'

module Proxy::Omaha
  class HttpRequest
    include Proxy::Log
    include HttpShared

    def get(url)
      Timeout::timeout(10) do
        response = get_recursive(url)

        raise "Error retrieving from #{url}: #{response.class}" unless ["200", "201"].include?(response.code)

        response.body
      end
    end

    def head(url)
      Timeout::timeout(10) do
        response = get_recursive(url, opts = {:method => :head})

        raise "Error retrieving from #{url}: #{response.class}" unless ["200", "201"].include?(response.code)

        response
      end
    end
  end
end
