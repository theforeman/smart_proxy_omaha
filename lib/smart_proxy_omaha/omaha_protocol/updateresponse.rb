module Proxy::Omaha::OmahaProtocol
  class Updateresponse < Response
    attr_reader :metadata, :release, :architecture, :sha1_b64, :name, :size, :sha256_b64, :server, :track

    def initialize(options = {})
      @metadata = options.fetch(:metadata)
      @architecture = options.fetch(:board)
      @name = 'update.gz'
      @size = metadata.size
      @sha1_b64 = metadata.sha1_b64
      @sha256_b64 = metadata.sha256_b64
      @release = metadata.release
      @track = metadata.track
      super
    end

    protected

    def xml_response(xml)
      xml.updatecheck(:status => 'ok') do
        xml.urls do
          xml.url(:codebase => "#{base_url}/omahareleases/#{track}/#{architecture}/#{release}/")
        end
        xml.manifest(:version => release) do
          xml.packages do
            xml.package(:hash => sha1_b64, :name => name, :size => size, :required => false)
          end
          xml.actions do
            xml.action(:event => 'postinstall', :sha256 => sha256_b64, :needsadmin => false, :IsDelta => false, :DisablePayloadBackoff => true, :ChromeOSVersion => '')
          end
        end
      end
    end
  end
end
