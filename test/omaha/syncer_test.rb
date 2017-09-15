require 'test_helper'
require 'smart_proxy_omaha/syncer'

class SyncerTest < Test::Unit::TestCase

  class FakeRelease
    def exists?
      false
    end

    def valid?
      true
    end

    def complete?
      true
    end

    def create; end
  end

  class FakeReleaseProvider
    def releases
      3.times.map { FakeRelease.new }
    end
  end

  def setup
    Proxy::Omaha::Plugin.load_test_settings({:sync_releases => 1})
    @provider = FakeReleaseProvider.new
    @syncer = Proxy::Omaha::Syncer.new
    @syncer.stubs(:release_provider).returns(@provider)
  end

  def test_sync
    FakeRelease.any_instance.expects(:create).times(3)
    @syncer.run
  end

  def test_sync_existing
    FakeRelease.any_instance.stubs(:exists?).returns(true)
    FakeRelease.any_instance.expects(:create).never
    @syncer.run
  end
end
