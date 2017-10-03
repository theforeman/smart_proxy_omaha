module Proxy::Omaha::OmahaProtocol
  class Pingresponse < Response
    protected

    def xml_response(xml)
      xml.ping(:status => 'ok')
    end
  end
end
