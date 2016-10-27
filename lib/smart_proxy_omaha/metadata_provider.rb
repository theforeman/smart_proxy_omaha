module Proxy::Omaha
  class MetadataProvider
    attr_accessor :contentpath

    def initialize(options)
      @contentpath = options.fetch(:contentpath)
    end

    def get(track, release)
      Metadata.new(JSON.parse(File.read(metadata_file(track, release))))
    end

    def store(metadata)
      File.open(metadata_file(metadata.track, metadata.release), 'w') do |file|
        file.write(metadata.to_json)
      end
      true
    end

    private

    def metadata_file(track, release)
      File.join(contentpath, track, release.to_s, 'metadata.json')
    end
  end
end
