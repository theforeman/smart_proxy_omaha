module Proxy::Omaha
  class Metadata
    attr_accessor :release, :sha1_b64, :sha256_b64, :size, :track

    def initialize(params)
      symbolize_keys_deep!(params)
      @release = params.fetch(:release)
      @sha1_b64 = params.fetch(:sha1_b64)
      @sha256_b64 = params.fetch(:sha256_b64)
      @size = params.fetch(:size)
      @track = params.fetch(:track)
    end

    def to_json
      {
        :release => release,
        :sha1_b64 => sha1_b64,
        :sha256_b64 => sha256_b64,
        :size => size,
        :track => track,
      }.to_json
    end

    private

    def symbolize_keys_deep!(h)
      h.keys.each do |k|
        ks    = k.to_sym
        h[ks] = h.delete k
        symbolize_keys_deep! h[ks] if h[ks].is_a? Hash
      end
    end
  end
end
