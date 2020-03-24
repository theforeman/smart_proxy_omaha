require 'smart_proxy_omaha/release'
require 'smart_proxy_omaha/track'
require 'smart_proxy_omaha/release_provider'
require 'smart_proxy_omaha/distribution'

module Proxy::Omaha
  class Syncer
    include ::Proxy::Log

    def run
      if sync_count == 0
        logger.info "Syncing is disabled."
        return
      end

      Proxy::Omaha::Track.all.each do |track|
        logger.debug "Syncing track: #{track}..."
        releases = release_provider(track).releases
        releases.last(sync_count).each do |release|
          sync_release(track, release)
        end
        update_current_release(track, releases.last) if releases.any?
      end
    end

    def sync_release(track, release)
      if release.exists?
        if !release.valid?
          logger.info "#{track} release #{release} is invalid. Purging."
          release.purge
        elsif release.complete?
          logger.info "#{track} release #{release} exists, is complete and valid. Skipping sync."
          return
        end
      end
      release.create
    end

    def update_current_release(track, release)
      logger.debug "#{track}: Updating current release to #{release}"
      release.mark_as_current!
    end

    private

    def sync_count
      Proxy::Omaha::Plugin.settings.sync_releases.to_i
    end

    def distribution
      Proxy::Omaha::Plugin.settings.distribution
    end

    def release_provider(track)
      @release_provider ||= {}
      @release_provider[track] ||= ReleaseProvider.new(
        :track => track,
        :distribution => ::Proxy::Omaha::Distribution.new(distribution)
      )
    end
  end
end
