module Proxy::Omaha::OmahaProtocol
  class Noupdateresponse < Response
    protected

    def xml_response(xml)
      xml.updatecheck(:status => 'noupdate')
    end
  end
end
