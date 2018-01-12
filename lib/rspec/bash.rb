require 'rspec/bash/command'
require 'rspec/bash/matchers'
require 'rspec/bash/server'
require 'rspec/bash/util'
require 'rspec/bash/wrapper'

require 'rspec/bash/mocking_adapter'
require 'rspec/bash/stubbed_env'

RSpec.configure do |c|
  c.mock_with Rspec::Bash::MockingAdapter
end
