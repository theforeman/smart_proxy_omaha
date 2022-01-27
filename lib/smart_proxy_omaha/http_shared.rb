require 'net/http'
require 'net/https'
require 'uri'

module Proxy::Omaha
  module HttpShared
    def connection_factory(url, opts = {})
      method = opts.fetch(:method, :get)
      uri = URI.parse(url)

      if Proxy::Omaha::Plugin.settings.proxy.to_s.empty?
        proxy_host = nil
        proxy_port = nil
      else
        proxy = URI.parse(Proxy::Omaha::Plugin.settings.proxy)
        proxy_host = proxy.host
        proxy_port = proxy.port
      end

      http = Net::HTTP.new(uri.host, uri.port, proxy_host, proxy_port)

      if uri.scheme == 'https'
        http.use_ssl = true
      end

      request_class = case method
                        when :get
                          Net::HTTP::Get
                        when :head
                          Net::HTTP::Head
                        else
                          raise "Unknown request class"
                        end
      request = request_class.new(uri.request_uri)

      [http, request]
    end

    def get_recursive(url, opts = {}, limit = 10)
      http, request = connection_factory(url, opts)
      response = http.request(request)
      response = get_recursive(response['location'], opts, limit - 1) if response.code == '302'

      response
    end
  end
end
