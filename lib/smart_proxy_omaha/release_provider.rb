require 'nokogiri'
require 'fileutils'
require 'smart_proxy_omaha/release'

module Proxy::Omaha
  class ReleaseProvider
    include ::Proxy::Log
    include HttpShared

    attr_reader :track, :architecture, :distribution

    def initialize(options)
      @track = options.fetch(:track)
      @architecture = options.fetch(:architecture, 'amd64-usr')
      @distribution = options.fetch(:distribution)
    end

    def releases
      @releases ||= fetch_releases
    end

    def fetch_releases
      releases = distribution.releases(track, architecture)
      release_objects = releases.map do |version|
        Proxy::Omaha::Release.new(:distribution => distribution, :version => version, :track => track, :architecture => architecture)
      end.sort
      logger.debug "Fetched releases for #{architecture}/#{track}: #{release_objects.map(&:to_s).join(', ')}"
      release_objects
    end
  end
end
