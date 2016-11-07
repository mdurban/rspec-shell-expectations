require 'rspec/expectations'
require 'differ'

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
      actual = [@actual_command.call_log.get_call_log_args.first.join(', ').gsub(/\,/,"")].first
      expected =  @expected_argument_list.first
      diff = Differ.diff_by_word(actual, expected).format_as(:color)
      "Expected [#{expected}] but got [#{actual}].\nDiff is #{diff}"
    end
  end

  def be_called_with_arguments(*expected)
    CalledWithArgumentsMatcher.new(*expected)
  end
end

RSpec::configure do |config|
  config.include(CustomMatchers)
end
