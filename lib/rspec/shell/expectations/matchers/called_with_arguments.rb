require 'rspec/expectations'

RSpec::Matchers.define :be_called_with_arguments do |*expected_argument_list|
  chain :at_position do |expected_argument_position|
    @expected_argument_position = expected_argument_position
  end

  chain :times do |expected_invocations|
      @expected_invocations = expected_invocations
  end

  match do |actual_command|
    actual_command.called_with_args?(*expected_argument_list, position: @expected_argument_position) and
      @expected_invocations ? actual_command.get_argument_count(*expected_argument_list) == @expected_invocations : true
  end
end
