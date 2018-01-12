require 'rspec/core/mocking_adapters/rspec'

module Rspec
  module Bash
    module MockingAdapter
      RSpec::Core::MockingAdapters::RSpec.send :module_function, :setup_mocks_for_rspec
      RSpec::Core::MockingAdapters::RSpec.send :module_function, :verify_mocks_for_rspec
      RSpec::Core::MockingAdapters::RSpec.send :module_function, :teardown_mocks_for_rspec
      include RSpec::Core::MockingAdapters::RSpec

      def self.framework_name
        :rspec_bash
      end

      def setup_mocks_for_rspec
        puts 'custom setup'
        ::RSpec::Core::MockingAdapters::RSpec.setup_mocks_for_rspec
      end

      def verify_mocks_for_rspec
        puts 'custom verify'
        ::RSpec::Core::MockingAdapters::RSpec.verify_mocks_for_rspec
      end

      def teardown_mocks_for_rspec
        puts 'custom teardown'
        ::RSpec::Core::MockingAdapters::RSpec.teardown_mocks_for_rspec
      end
    end
  end
end
