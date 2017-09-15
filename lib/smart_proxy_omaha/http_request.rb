require 'smart_proxy_omaha/http_shared'

module Proxy::Omaha
  class HttpRequest
    include Proxy::Log
    include HttpShared

    def get(url)
      http, request = connection_factory(url)

      Timeout::timeout(10) do
        response = http.request(request)

        raise "Error retrieving from #{url}: #{response.class}" unless ["200", "201"].include?(response.code)

        response.body
      end
    end

    def head(url)
      http, request = connection_factory(url, :method => :head)

      Timeout::timeout(10) do
        response = http.request(request)

        raise "Error retrieving from #{url}: #{response.class}" unless ["200", "201"].include?(response.code)

        response
      end
    end
  end
end
