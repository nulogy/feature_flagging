# FeatureFlagging

Thin wrapper around LaunchDarkly for setting up and accessing feature flags.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'feature_flagging'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install feature_flagging

Then add it to the relevant initializers:

```ruby
launchdarkly_config_hash = YAML.load(File.read("launchdarkly.yml"))
FeatureFlagging::Configuration.start_client(launchdarkly_config_hash[:sdk_key])
```

For example in `config/puma.rb`:

```ruby
launchdarkly_config_hash = YAML.load(File.read("launchdarkly.yml"))
FeatureFlagging::Configuration.start_client(launchdarkly_config_hash[:sdk_key])
```

In `config/unicorn.rb`:

```ruby
after_fork do |_server, _worker|
  launchdarkly_config_hash = YAML.load(File.read("launchdarkly.yml"))
  FeatureFlagging::Configuration.start_client(launchdarkly_config_hash[:sdk_key])
end
```

In `config/initializers/feature_flagging.rb` for all tests:

```ruby
if Rails.env.test?
  launchdarkly_config_hash = YAML.load(File.read("launchdarkly.yml"))
  FeatureFlagging::Configuration.start_client(launchdarkly_config_hash[:sdk_key])
end
```

## Usage

### Adapter over this gem

You may want to create a slim adapter over this FeatureFlagging gem to be the
entry point for using flags. It knows how to build the user information to send 
to the feature flagging service.

```ruby
class FeatureFlags
  def self.evaluate(key, default)
    new.evaluate(key, default)
  end

  def self.all_flags_state
    new.all_flags_state
  end

  def evaluate(key, default)
    FeatureFlagging::FeatureFlags.evaluate(key, user_info, default)
  end

  def all_flags_state
    FeatureFlagging::FeatureFlags.all_flags_state(user_info)
  end

  private

  def user_info
    Current.user ? signed_in_user_info : anonymous_user_info
  end

  def signed_in_user_info
    {
      key: Current.user.uuid,
      anonymous: false,
      custom: {
        evaluation_datetime: Time.now.utc.to_i * 1000,
        site_id: Current.site.uuid,
        account_id: Current.account.uuid,
        company_id: Current.company.uuid
      }
    }
  end

  def anonymous_user_info
    {
      key: UuidAdapter.generate_uuid,
      anonymous: true,
      custom: {
        evaluation_datetime: Time.now.utc.to_i * 1000
      }
    }
  end
end
```

### Tests

In your `spec_helper`, make sure you reset the `SpecStore`:

```ruby
RSpec.configure do |config|
  config.before do
    FeatureFlagging::SpecUtils.reset
  end
end
```

Then use it like this in a spec to set up a feature flag in memory:

```ruby
RSpec.describe TestController do
  it "returns the OFF variation when that is received" do
    FeatureFlagging::SpecUtils.set_flag_variation(:connectivity_diagnostics_test, "\"OFF\" Variation Served from Spec")
  
    get :feature_flagging
  
    expect(response).to be_successful
    expect(response.body).to eq("\"OFF\" Variation Served from Spec")
  end
end
```
