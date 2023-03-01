# frozen_string_literal: true

require 'smart_proxy_omaha/http_request'

module Proxy
  module Omaha
    module Distribution
      def self.new(distribution)
        case distribution
        when 'coreos'
          Coreos.new
        when 'flatcar'
          Flatcar.new
        else
          raise 'Unsupported distribution.'
        end
      end

      class Base
        private

        def http_request
          @http_request ||= ::Proxy::Omaha::HttpRequest.new
        end
      end

      class Coreos < Base
        def identifier
          :coreos
        end

        def prefix
          'coreos'
        end

        def update_filename
          'update.gz'
        end

        def upstream(track, architecture, version)
          "https://#{track}.release.core-os.net/#{architecture}/#{version}"
        end

        def update_upstream(architecture, version)
          "https://update.release.core-os.net/#{architecture}/#{version}"
        end

        def releases(track, architecture)
          release_data = http_request.get("https://#{track}.release.core-os.net/#{architecture}/")
          xml = Nokogiri::HTML(release_data)
          (xml.xpath('//a/text()').map(&:to_s) - ['current'])
        end
      end

      class Flatcar < Base
        def identifier
          :flatcar
        end

        def prefix
          'flatcar'
        end

        def update_filename
          'flatcar_production_update.gz'
        end

        def upstream(track, architecture, version)
          "https://#{track}.release.flatcar-linux.net/#{architecture}/#{version}"
        end

        def update_upstream(architecture, version)
          "https://update.release.flatcar-linux.net/#{architecture}/#{version}"
        end

        def releases(track, architecture)
          feed_data = http_request.get("https://www.flatcar-linux.org/releases-json/releases-#{track}.json")
          json_feed = JSON.parse(feed_data)
          json_feed.select do |_, release|
            release['architectures'].include?(architecture.split('-').first)
          end.keys - ['current']
        end
      end
    end
  end
end
