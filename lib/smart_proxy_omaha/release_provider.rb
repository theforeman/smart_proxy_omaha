require 'nokogiri'
require 'fileutils'
require 'smart_proxy_omaha/http_request'
require 'smart_proxy_omaha/release'

module Proxy::Omaha
  class ReleaseProvider
    include ::Proxy::Log
    include HttpShared

    attr_accessor :track
    attr_accessor :architecture

    def initialize(options)
      @track = options.fetch(:track)
      @architecture = options.fetch(:architecture, 'amd64-usr')
    end

    def releases
      @releases ||= fetch_releases
    end

    def fetch_releases
      releases = http_request.get("https://#{track}.release.core-os.net/#{architecture}/")
      xml = Nokogiri::HTML(releases)
      parsed = (xml.xpath('//a/text()').map(&:to_s) - ['current']).map do |v|
        Proxy::Omaha::Release.new(:version => v, :track => track, :architecture => architecture)
      end.sort
      logger.debug "Fetched releases for #{architecture}/#{track}: #{parsed.map(&:to_s).join(', ')}"
      parsed
    end

    private

    def http_request
      @http_request ||= ::Proxy::Omaha::HttpRequest.new
    end
  end
end
