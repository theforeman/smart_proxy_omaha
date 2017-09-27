module Proxy
  module Omaha
    module Track
      TRACKS = ['alpha', 'beta', 'stable'].freeze

      def self.all
        TRACKS
      end

      def self.valid?(track)
        all.include?(track)
      end
    end
  end
end
