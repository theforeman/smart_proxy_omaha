require 'fileutils'
require 'digest/md5'
require 'smart_proxy_omaha/http_download'
require 'smart_proxy_omaha/metadata_provider'

module Proxy::Omaha
  class Release
    include Proxy::Log

    attr_accessor :track, :version, :architecture
    attr_writer :digests

    def initialize(options)
      @track = options.fetch(:track).to_s
      @architecture = options.fetch(:architecture)
      @version = Gem::Version.new(options.fetch(:version))
    end

    def base_path
      @base_path ||= File.join(Proxy::Omaha::Plugin.settings.contentpath, track, architecture)
    end

    def path
      @path ||= File.join(base_path, version.to_s)
    end

    def current_path
      @current_path ||= File.join(base_path, 'current')
    end

    def metadata
      metadata_provider.get(track, release, architecture)
    end

    def exists?
      File.directory?(path)
    end

    def valid?
      existing_files.select { |file| file !~ /\.(DIGESTS|sig)$/ }.map do |file|
        next unless digests[file]
        digests[file].include?(Digest::MD5.file(File.join(path, file)).hexdigest)
      end.compact.all?
    end

    def create
      logger.debug "Creating #{track} #{version} #{architecture}"
      return false unless create_path
      return false unless download
      return false unless create_metadata
      true
    end

    def current?
      return false unless File.symlink?(current_path)
      File.readlink(current_path) == path
    end

    def mark_as_current!
      return true if current?
      File.unlink(current_path) if File.symlink?(current_path)
      FileUtils.ln_s(path, current_path)
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
        next if file_exists?(file)
        dst = File.join(path, file)
        logger.debug "Downloading file #{url} to #{dst}"
        task = ::Proxy::Omaha::HttpDownload.new(url, dst)
        task.start
        task
      end.compact.each(&:join).map(&:result).all?
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
        "#{upstream}/coreos_production_pxe.DIGESTS",
        "#{upstream}/coreos_production_image.bin.bz2",
        "#{upstream}/coreos_production_image.bin.bz2.sig",
        "#{upstream}/coreos_production_image.bin.bz2.DIGESTS",
        "#{upstream}/coreos_production_pxe_image.cpio.gz",
        "#{upstream}/coreos_production_pxe_image.cpio.gz.DIGESTS",
        "#{upstream}/coreos_production_vmware_raw_image.bin.bz2",
        "#{upstream}/coreos_production_vmware_raw_image.bin.bz2.sig",
        "#{upstream}/coreos_production_vmware_raw_image.bin.bz2.DIGESTS",
        "#{upstream}/version.txt",
        "#{upstream}/version.txt.DIGESTS",
        "https://update.release.core-os.net/#{architecture}/#{version}/update.gz"
      ]
    end

    def expected_files
      sources.map { |source| File.basename(source) }
    end

    def existing_files
      Dir.glob(File.join(path, '*')).map { |file| File.basename(file) }
    end

    def missing_files
      expected_files - existing_files
    end

    def digest_files
      Dir.glob(File.join(path, '*.DIGESTS')).map { |file| File.basename(file) }
    end

    def complete?
      missing_files.empty?
    end

    def file_exists?(file)
      File.file?(File.join(path, file))
    end

    def purge
      FileUtils.rm(Dir.glob(File.join(path, '*')), :force => true)
      FileUtils.remove_dir(path)
      true
    rescue
      false
    end

    def digests
      @digests ||= load_digests!
    end

    def load_digests!
      self.digests = {}
      digest_files.each do |digest_file|
        file = File.basename(digest_file, '.DIGESTS')
        File.readlines(File.join(path, digest_file)).each do |line|
          next unless line =~ /^\w+[ ]+\S+$/
          hexdigest = line.split(/[ ]+/).first
          self.digests[file] ||= []
          self.digests[file] << hexdigest
        end
      end
      self.digests
    end

    private

    def metadata_provider
      MetadataProvider.new(
        :contentpath => Proxy::Omaha::Plugin.settings.contentpath
      )
    end
  end
end
