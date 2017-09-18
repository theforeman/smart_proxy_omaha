require 'test_helper'
require 'tmpdir'
require 'smart_proxy_omaha/release_repository'

class ReleaseRepositoryTest < Test::Unit::TestCase
  def setup
    @contentpath = Dir.mktmpdir
    Proxy::Omaha::Plugin.load_test_settings(
      {
        :contentpath => @contentpath
      }
    )
    @repository = Proxy::Omaha::ReleaseRepository.new
  end

  def teardown
    FileUtils.rm_rf(@contentpath)
  end

  def test_releases
    test_releases = [
      '197.0.0', '206.0.0', '206.1.0', '225.1.0', '225.2.0', '226.0.0'
    ]
    test_releases.each do |test_release|
      FileUtils.mkdir_p(release_path(test_release))
    end

    FileUtils.ln_s(release_path('current'), release_path('226.0.0'))

    releases = @repository.releases('alpha', 'amd64-usr')
    assert_equal test_releases.sort, releases.map(&:to_s).sort
    assert_equal '226.0.0', @repository.latest_os('alpha', 'amd64-usr').to_s
  end

  private

  def release_path(version)
    File.join(@contentpath, 'alpha', 'amd64-usr', version)
  end
end
