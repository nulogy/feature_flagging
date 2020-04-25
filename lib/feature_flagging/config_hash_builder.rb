module FeatureFlagging
  module ConfigHashBuilder
    extend self

    FLAG_VALUES_FILE = "config/launchdarkly_flag_values.yml"
    LOCAL_FLAG_VALUES_FILE = "config/launchdarkly_flag_values_local.yml"

    def online_mode
      {
        logger: ActiveSupport::Logger.new(STDOUT),
        send_events: true
      }
    end

    def offline_production_mode
      factory = LaunchDarkly::FileDataSource.factory(
        paths: [local_flag_values_file],
        auto_update: true
      )
      {
        send_events: false,
        update_processor_factory: factory
      }
    end

    def offline_development_mode
      factory = LaunchDarkly::FileDataSource.factory(
        paths: [local_flag_values_file],
        auto_update: true
      )
      {
        send_events: false,
        update_processor_factory: factory
      }
    end

    def offline_test_mode
      Rails.configuration.ld_spec_store = SpecStore.new

      factory = LaunchDarkly::FileDataSource.factory(
        paths: [flag_values_file]
      )
      {
        data_source: factory,
        send_events: false,
        feature_store: Rails.configuration.ld_spec_store
      }
    end

    private

    def local_flag_values_file
      local_file = Rails.root.join(LOCAL_FLAG_VALUES_FILE)
      File.exist?(local_file) ? local_file : flag_values_file
    end

    def flag_values_file
      Rails.root.join(FLAG_VALUES_FILE)
    end
  end
end
