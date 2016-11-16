require 'rspec/bash'

describe 'be_called_with_arguments' do
  include Rspec::Bash
  let(:call_log_mock) { object_double('CallLog') }
  let(:stubbed_command_mock) { object_double('StubbedCommand') }

  context '#matches' do
    it 'matches when stubbed command is called with same arguments' do
      allow(stubbed_command_mock).to receive(:called_with_args?).and_return(true)

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(anything)

      expect(matcher.matches? stubbed_command_mock).to be_truthy
    end
    
    it 'does not match when stubbed command is called with different arguments' do
      allow(stubbed_command_mock).to receive(:called_with_args?).and_return(false)

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(anything)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
    end
  end

  context '#failure_message' do
    before(:each) do
      allow(call_log_mock).to receive(:get_call_log_args).and_return([['actual1', 'actual2']])
      allow(stubbed_command_mock).to receive(:called_with_args?).and_return(false)
    end
    
    it 'returns message that shows expected and actual arguments when matcher fails' do
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'expected1 expected2'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
      expect(matcher.failure_message).to include 'Expected [expected1 expected2] but got [actual1 actual2].'
    end
    
    it 'returns message that shows colorful diff expected matches one argument but is missing the other' do
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'actual1'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
      expect(matcher.failure_message).to include "Diff is actual1\e[32m actual2\e[0m" #color codes included
    end

    it 'returns diff that shows which argument is out of order when expected matches one argument but is missing the other' do
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'actual2 actual1'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
      expect(matcher.failure_message).to include "Diff is \e[31mactual2 \e[0mactual1\e[32m actual2\e[0m" #color codes included
    end

    it 'returns diff that shows which argument is extra when all arguments match but there is an extra' do
      allow(stubbed_command_mock).to receive(:call_log).and_return(call_log_mock)
      expected_argument_list = 'actual1 actual2 extra_arg, extra_arg2'

      matcher = CustomMatchers::CalledWithArgumentsMatcher.new(expected_argument_list)

      expect(matcher.matches? stubbed_command_mock).to be_falsey
      expect(matcher.failure_message).to include "Diff is actual1 actual2\e[31m extra_arg, extra_arg2\e[0m" #color codes included
    end

  end
end
