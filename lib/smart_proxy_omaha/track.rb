module Proxy
  module Omaha
    module Track
      TRACKS = ['alpha', 'beta', 'stable'].freeze # edge

      def self.all
        TRACKS
      end

      def self.valid?(track)
        all.include?(track)
      end
    end
  end
end
