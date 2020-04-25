require "ldclient-rb"

module FeatureFlagging
  class Configuration
    def self.start_client(sdk_key)
      config = configure(sdk_key)

      Rails.configuration.ld_client = LaunchDarkly::LDClient.new(sdk_key, config)
    end

    def self.configure(sdk_key)
      new(sdk_key).configure
    end

    def initialize(sdk_key)
      @sdk_key = sdk_key
    end

    def configure
      LaunchDarkly::Config.new(config_hash)
    end

    private

    def config_hash
      if @sdk_key
        Rails.logger.info("Starting LaunchDarkly client in online mode")
        ConfigHashBuilder.online_mode
      elsif Rails.env.production?
        Rails.logger.info("Starting LaunchDarkly client in offline production mode")
        ConfigHashBuilder.offline_production_mode
      elsif Rails.env.development?
        Rails.logger.info("Starting LaunchDarkly client in offline development mode")
        ConfigHashBuilder.offline_development_mode
      elsif Rails.env.test?
        Rails.logger.info("Starting LaunchDarkly client in offline test mode")
        ConfigHashBuilder.offline_test_mode
      end
    end
  end
end
