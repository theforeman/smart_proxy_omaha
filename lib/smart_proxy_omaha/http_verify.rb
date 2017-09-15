module Proxy::Omaha
  class HttpVerify
    include Proxy::Log

    attr_accessor :remote_url, :local_file, :filename

    def initialize(opts = {})
      self.remote_url = opts.fetch(:remote_url)
      self.local_file = opts.fetch(:local_file)
      self.filename = File.basename(local_file)
    end

    def http_request
      @http_request ||= ::Proxy::Omaha::HttpRequest.new.head(remote_url)
    end

    def valid?
      logger.debug "#{filename}: Verifying if file is valid."
      return false unless file_size_valid?
      return false if headers['x-goog-hash'] && !md5_hash_valid?
      true
    end

    def file_size_valid?
      unless local_size == remote_size
        logger.debug "#{filename}: File sizes do not match. Remote: #{remote_size}, Local: #{local_size}"
        return false
      end
      true
    end

    def local_size
      File.size(local_file)
    end

    def remote_size
      headers['content-length'].first.to_i
    end

    def md5_hash_valid?
      unless local_md5 == remote_md5
        logger.debug "#{filename}: MD5 checksums do not match. Remote: #{remote_md5}, Local: #{local_md5}"
        return false
      end
      true
    end

    def remote_hashes
      headers['x-goog-hash'].inject({}) do |hsh, header|
        key, value = header.split('=', 2)
        hsh[key] = value
        hsh
      end
    end

    def local_md5
      Digest::MD5.file(local_file).base64digest
    end

    def remote_md5
      remote_hashes['md5']
    end

    def headers
      @headers ||= http_request.to_hash
    end
  end
end
