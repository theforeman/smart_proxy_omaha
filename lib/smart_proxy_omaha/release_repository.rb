require 'smart_proxy_omaha/release'

module Proxy::Omaha
  class ReleaseRepository

    attr_reader :contentpath, :distribution

    def initialize(options)
      @contentpath = options.fetch(:contentpath)
      @distribution = options.fetch(:distribution)
    end

    def releases(track, architecture)
      Dir.glob(File.join(contentpath, track, architecture, '*')).select do |f|
        File.directory?(f) && ! File.symlink?(f)
      end.map do |f|
        Proxy::Omaha::Release.new(
          :distribution => distribution,
          :track => track,
          :architecture => architecture,
          :version => File.basename(f)
        )
      end
    end

    def tracks
      Dir.glob(File.join(contentpath, '*')).select {|f| File.directory? f }.map { |f| File.basename(f) }
    end

    def architectures(track)
      Dir.glob(File.join(contentpath, track, '*')).select {|f| File.directory? f }.map { |f| File.basename(f) }
    end

    def latest_os(track, architecture)
      releases(track, architecture).max
    end
  end
end
