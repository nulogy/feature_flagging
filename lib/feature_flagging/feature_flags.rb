module FeatureFlagging
  class FeatureFlags
    def self.evaluate(key, user_info, default)
      Rails.configuration.ld_client.variation(key, user_info, default)
    end

    def self.all_flags_state(user_info)
      Rails.configuration.ld_client.all_flags_state(user_info).values_map.to_json
    end
  end
end
