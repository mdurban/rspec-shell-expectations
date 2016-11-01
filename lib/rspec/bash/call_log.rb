module Rspec
  module Bash
    # Log of calls to a command
    class CallLog
      def initialize(call_log_path)
        @call_log_path = call_log_path
      end

      def exist?
        @call_log_path.exist?
      end

      def called_with_args?(*args)
        call_count(*args) > 0
      end

      def stdin_for_args(*args)
        call = find_call(*args)
        call['stdin'] unless call.nil?
      end

      def call_count(*expected_argument_series)
        get_call_log_args.count do |actual_argument_series|
          argument_series_contains?(actual_argument_series, expected_argument_series || [])
        end
      end

      def get_call_log_args
        load_call_log_list.map { |call_log| call_log["args"] || [] }.compact
      end

      def called_with_no_args?
        call_log_list = load_call_log_list
        !call_log_list.empty? && call_log_list.first['args'].nil?
      end

      private

      def find_call(*args)
        load_call_log_list.find do |call|
          call_args = call['args'] || []
          (args - call_args).empty?
        end
      end

      def get_position_range_from_argument_list(argument_list, range_start_position, range_length)
        argument_list.map do |argument_series|
          range_start_position ? argument_series[range_start_position, range_length] : argument_series
        end
      end

      def argument_series_contains?(actual_argument_series, expected_argument_series)
        ensure_wildcards_match(actual_argument_series, expected_argument_series)
        expected_argument_series.empty? || (actual_argument_series == expected_argument_series)
      end

      def ensure_wildcards_match(actual_argument_series, expected_argument_series)
        # yes, i know. i am disappointed in myself
        num_of_args = actual_argument_series.size
        expected_argument_series.zip((0..num_of_args), actual_argument_series) do |expected_arg, index, _actual_arg|
          if expected_arg.is_a? RSpec::Mocks::ArgumentMatchers::AnyArgMatcher
            actual_argument_series[index] = expected_arg
          end
        end
      end

      def load_call_log_list
        begin
          YAML.load_file @call_log_path
        rescue Errno::ENOENT
          return []
        end
      end

    end
  end
end
