require 'uri'

module Proxy::Omaha::OmahaProtocol
  class Response
    include ::Proxy::Log

    attr_reader :appid, :base_url, :host, :status

    def initialize(options = {})
      @appid = options.fetch(:appid)
      @base_url = options.fetch(:base_url)
      @host = URI.parse(base_url).host
      @status = options.fetch(:status, 'ok')
    end

    def to_xml
      xml.to_xml
    end

    def http_status
      200
    end

    protected

    def xml
      @xml ||= Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.response(:protocol => '3.0', :server => host) do
          xml.daystart(:elapsed_seconds => 0)
          xml.app(:app_id => appid, :status => status) do
            xml_response(xml)
          end
        end
      end
    end
  end
end
