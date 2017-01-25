module Proxy::Omaha
  class ReleaseRepository
    def releases(track, architecture)
      Dir.glob(File.join(Proxy::Omaha::Plugin.settings.contentpath, track, architecture, '*')).select {|f| File.directory? f }.map { |f| Gem::Version.new(File.basename(f)) }
    end

    def latest_os(track, architecture)
      releases(track, architecture).max
    end
  end
end
