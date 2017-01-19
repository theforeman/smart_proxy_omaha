require 'fileutils'
require 'smart_proxy_omaha/http_download'
require 'smart_proxy_omaha/metadata_provider'

module Proxy::Omaha
  class Release
    include Proxy::Log

    attr_accessor :track, :version, :architecture

    def initialize(options)
      @track = options.fetch(:track).to_s
      @architecture = options.fetch(:architecture)
      @version = Gem::Version.new(options.fetch(:version))
    end

    def path
      @path ||= File.join(Proxy::Omaha::Plugin.settings.contentpath, track, architecture, version.to_s)
    end

    def metadata
      metadata_provider.get(track, release, architecture)
    end

    def exists?
      File.directory?(path)
    end

    def valid?
      expected_files_exist?
    end

    def create
      logger.debug "Creating #{track} #{version} #{architecture}"
      return false unless create_path
      return false unless download
      return false unless create_metadata
      true
    end

    def <=>(other)
      return unless self.class === other
      version.<=>(other.version)
    end

    def ==(other)
      self.class === other && track == other.track && version == other.version && architecture == other.architecture
    end

    def to_s
      version.to_s
    end

    def download
      sources.map do |url|
        file = URI.parse(url).path.split('/').last
        dst = File.join(path, file)
        logger.debug "Downloading file #{url} to #{dst}"
        task = ::Proxy::Omaha::HttpDownload.new(url, dst)
        task.start
        task
      end.each(&:join).map(&:result).all?
    end

    def create_metadata
      metadata_provider.store(Metadata.new(
        :track => track,
        :release => version.to_s,
        :architecture => architecture,
        :size => File.size(updatefile),
        :sha1_b64 => Digest::SHA1.file(updatefile).base64digest,
        :sha256_b64 => Digest::SHA256.file(updatefile).base64digest
      ))
      true
    rescue
      false
    end

    def create_path
      FileUtils.mkdir_p(path)
      true
    rescue
      false
    end

    def updatefile
      File.join(path, 'update.gz')
    end

    def sources
      upstream = "https://#{track}.release.core-os.net/#{architecture}/#{version}"
      [
        "#{upstream}/coreos_production_pxe.vmlinuz",
        "#{upstream}/coreos_production_image.bin.bz2",
        "#{upstream}/coreos_production_image.bin.bz2.sig",
        "#{upstream}/coreos_production_pxe_image.cpio.gz",
        "https://update.release.core-os.net/#{architecture}/#{version}/update.gz"
      ]
    end

    def expected_files
      sources.map { |source| File.basename(source) }
    end

    def expected_files_exist?
      expected_files.map {|file| File.file?(File.join(path, file)) }.all?
    end

    def purge
      FileUtils.rm(Dir.glob(File.join(path, '*')), :force => true)
      FileUtils.remove_dir(path)
      true
    rescue
      false
    end

    private

    def metadata_provider
      MetadataProvider.new(
        :contentpath => Proxy::Omaha::Plugin.settings.contentpath
      )
    end
  end
end
