module Proxy::Omaha::OmahaProtocol
  class Errorinternalresponse < Response

    def http_status
      500
    end

    protected

    def xml_response(xml); end
  end
end
