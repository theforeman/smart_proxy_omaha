require 'smart_proxy_omaha/release'
require 'smart_proxy_omaha/release_provider'

module Proxy::Omaha
  class Syncer
    include ::Proxy::Log

    def run
      if sync_count == 0
        logger.info "Syncing is disabled."
        return
      end

      ['alpha', 'beta', 'stable'].each do |track|
        logger.debug "Syncing track: #{track}..."
        sync_track(track)
      end
    end

    def sync_track(track)
      release_provider(track).releases.last(sync_count).each do |release|
        if release.exists?
          if !release.valid?
            logger.info "#{track} release #{release} is invalid. Purging."
            release.purge
          elsif release.complete?
            logger.info "#{track} release #{release} exists, is complete and valid. Skipping sync."
            next
          end
        end
        release.create
      end
    end

    private

    def sync_count
      Proxy::Omaha::Plugin.settings.sync_releases.to_i
    end

    def release_provider(track)
      @release_provider ||= {}
      @release_provider[track] ||= ReleaseProvider.new(
        :track => track
      )
    end
  end
end
