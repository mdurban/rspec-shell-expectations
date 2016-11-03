require 'rspec/expectations'

module CustomMatchers
  class CalledWithArgumentsMatcher
    def initialize(*expected_argument_list)
      @expected_argument_list = expected_argument_list
    end

    def matches?(actual_command)
      @actual_command = actual_command

      called_with_correct_args = actual_command.called_with_args?(*@expected_argument_list)
      called_correct_number_of_times = @expected_invocations ? actual_command.call_count(*@expected_argument_list) == @expected_invocations : true

      called_with_correct_args && called_correct_number_of_times
    end

    def times(expected_invocations)
      @expected_invocations = expected_invocations
      self
    end
    
    def failure_message
      actual_argument_list = @actual_command.call_log.get_call_log_args.flatten
      expected_argument_list = @expected_argument_list.first.split(" ")
      missing_argument_list = actual_argument_list.reject.with_index do |arg, index|
        @expected_argument_list[index] == arg
      end

      'Expected to be called with arguments [' + @expected_argument_list.join(', ') + '] but was actually called with arguments [' + actual_argument_list.join(', ') + ']. Arguments [' + missing_argument_list.join(', ') + '] are missing or in incorrect order.'
    end
  end

  def be_called_with_arguments(*expected)
    CalledWithArgumentsMatcher.new(*expected)
  end
end

RSpec::configure do |config|
  config.include(CustomMatchers)
end
