require 'rspec/bash'

describe 'be_called_with_arguments' do
  include Rspec::Bash

  context '#failure_message' do
    it 'returns empty string when matcher is successful' do
      call_log_mock = object_double("CallLog")
      stubbed_command_mock = object_double("StubbedCommand")
      allow(call_log_mock).to receive(:get_call_log_args).and_return([['first_arg', 'second_arg']])
      allow(stubbed_command_mock).to receive(:called_with_args?).and_return(true)
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'first_arg second_arg'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_truthy
      expect(matcher.failure_message).to eql ''
    end
    
    it 'returns useful message when matcher fails' do
      call_log_mock = object_double("CallLog")
      stubbed_command_mock = object_double("StubbedCommand")
      allow(call_log_mock).to receive(:get_call_log_args).and_return([['1', '2']])
      allow(stubbed_command_mock).to receive(:called_with_args?).and_return(false)
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'first_arg second_arg'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
      expect(matcher.failure_message).to eql 'hi'
    end
  end
end
