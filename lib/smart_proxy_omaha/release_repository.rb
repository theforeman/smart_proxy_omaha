require 'smart_proxy_omaha/release'

module Proxy::Omaha
  class ReleaseRepository
    def releases(track, architecture)
      Dir.glob(File.join(Proxy::Omaha::Plugin.settings.contentpath, track, architecture, '*')).select do |f|
        File.directory?(f) && ! File.symlink?(f)
      end.map do |f|
        Proxy::Omaha::Release.new(
          :track => track,
          :architecture => architecture,
          :version => File.basename(f)
        )
      end
    end

    def tracks
      Dir.glob(File.join(Proxy::Omaha::Plugin.settings.contentpath, '*')).select {|f| File.directory? f }.map { |f| File.basename(f) }
    end

    def architectures(track)
      Dir.glob(File.join(Proxy::Omaha::Plugin.settings.contentpath, track, '*')).select {|f| File.directory? f }.map { |f| File.basename(f) }
    end

    def latest_os(track, architecture)
      releases(track, architecture).max
    end
  end
end
