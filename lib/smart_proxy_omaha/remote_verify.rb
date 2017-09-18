require 'smart_proxy_omaha/http_verify'

module Proxy::Omaha
  class RemoteVerify < HttpVerify
    include Proxy::Log

    attr_accessor :remote_url

    def initialize(opts = {})
      self.remote_url = opts.fetch(:remote_url)
      super(opts.merge(:http_request => http_request))
    end

    def http_request
      @http_request ||= ::Proxy::Omaha::HttpRequest.new.head(remote_url)
    end
  end
end
