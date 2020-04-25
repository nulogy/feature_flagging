require "concurrent/atomics"

module FeatureFlagging
  class SpecStore
    include LaunchDarkly::Interfaces::FeatureStore

    def initialize
      @items = {}
      @lock = Concurrent::ReadWriteLock.new
      @initialized = Concurrent::AtomicBoolean.new(false)
    end

    def get(kind, key)
      @lock.with_read_lock do
        coll = @items[kind]
        f = coll.nil? ? nil : coll[key.to_sym]
        f.nil? || f[:deleted] ? nil : f
      end
    end

    def all(kind)
      @lock.with_read_lock do
        coll = @items[kind]
        (coll.nil? ? {} : coll).reject { |_k, f| f[:deleted] }
      end
    end

    def delete(kind, key, version)
      @lock.with_write_lock do
        coll = @items[kind]
        if coll.nil?
          coll = {}
          @items[kind] = coll
        end

        coll[key.to_sym] = { deleted: true, version: version }
      end
    end

    def init(all_data)
      features_with_initial_variations = all_data[LaunchDarkly::FEATURES]
        .transform_values { |feature_data| feature_data.merge(initial_variations: feature_data[:variations].dup) }
      all_data_with_initial_variations = all_data.merge(LaunchDarkly::FEATURES => features_with_initial_variations)

      @lock.with_write_lock do
        @items.replace(all_data_with_initial_variations)
        @initialized.make_true
      end
    end

    def reset
      @lock.with_write_lock do
        @items[LaunchDarkly::FEATURES] = @items[LaunchDarkly::FEATURES].transform_values do |feature_data|
          feature_data.merge(variations: feature_data[:initial_variations].dup)
        end
      end
    end

    def upsert(kind, item)
      @lock.with_write_lock do
        coll = @items[kind]
        if coll.nil?
          coll = {}
          @items[kind] = coll
        end

        coll[item[:key].to_sym] = item
      end
    end

    def enable_flag(name)
      set_flag_variation(name, true)
    end

    def disable_flag(name)
      set_flag_variation(name, false)
    end

    def set_flag_variation(name, variation)
      @lock.with_write_lock do
        coll = @items[LaunchDarkly::FEATURES]
        if coll.nil?
          coll = {}
          @items[LaunchDarkly::FEATURES] = coll
        end

        coll[name.to_sym][:variations][0] = variation
      end
    end

    def initialized?
      @initialized.value
    end

    def stop
      # nothing to do
    end
  end
end
