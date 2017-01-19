module Proxy::Omaha
  class MetadataProvider
    attr_accessor :contentpath

    def initialize(options)
      @contentpath = options.fetch(:contentpath)
    end

    def get(track, release, architecture)
      Metadata.new(JSON.parse(File.read(metadata_file(track, release, architecture))))
    end

    def store(metadata)
      File.open(metadata_file(metadata.track, metadata.release, metadata.architecture), 'w') do |file|
        file.write(metadata.to_json)
      end
      true
    end

    private

    def metadata_file(track, release, architecture)
      File.join(contentpath, track, architecture, release.to_s, 'metadata.json')
    end
  end
end
