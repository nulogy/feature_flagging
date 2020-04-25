module FeatureFlagging
  class SpecUtils
    def self.reset
      Rails.configuration.ld_spec_store.reset
    end

    def self.set_flag_variation(flag, variation)
      Rails.configuration.ld_spec_store.set_flag_variation(flag, variation)
    end
  end
end
