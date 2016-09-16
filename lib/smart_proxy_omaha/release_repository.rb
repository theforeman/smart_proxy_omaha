module Proxy::Omaha
  class ReleaseRepository
    def releases(track)
      Dir.glob(File.join(Proxy::Omaha::Plugin.settings.contentpath, track, '*')).select {|f| File.directory? f }.map { |f| Gem::Version.new(File.basename(f)) }
    end

    def latest_os(track)
      releases(track).max
    end
  end
end
