module Rspec
  module Shell
    module Expectations
      # Log of calls to a command
      class CallLog
        def initialize(call_log_path)
          @call_log_path = call_log_path
        end

        def exist?
          @call_log_path.exist?
        end

        def called_with_args?(*args)
          contains_argument_series?(*args)
        end

        def stdin_for_args(*args)
          call = find_call(*args)
          call['stdin'] unless call.nil?
        end

        def contains_argument_series?(*contains_arguments)
          get_argument_count(*contains_arguments) > 0
        end

        def get_argument_count(*expected_argument_series, sub_command_series: [], position: false)
          expected_argument_series ||= []

          call_log_list = load_call_log_list
          sub_command_argument_list = get_sub_command_arguments_from_call_log(call_log_list, sub_command_series)
          position_range_argument_list = get_position_range_from_argument_list(sub_command_argument_list, position, expected_argument_series.size)

          position_range_argument_list.count do |actual_argument_series|
            argument_series_contains?(actual_argument_series, expected_argument_series)
          end
        end

        def called_with_no_args?
          call_log_list = load_call_log_list
          !call_log_list.empty? and call_log_list.first["args"].nil?
        end

        private

        def find_call(*args)
          load_call_log_list.each do |call|
            call_args = call['args'] || []
            return call if (args - call_args).empty?
          end
          nil
        end

        def get_sub_command_arguments_from_call_log(call_log_list, sub_command_list)
          call_log_list.map { |call_log|
            call_log_argument_series = call_log['args'] || []

            next call_log_argument_series if sub_command_list.empty?
            next call_log_argument_series if call_log_argument_series.slice!(0, sub_command_list.size) == sub_command_list
          }.compact
        end

        def get_position_range_from_argument_list(argument_list, range_start_position, range_length)
          argument_list.map { |argument_series|
            range_start_position ? argument_series[range_start_position, range_length] : argument_series
          }
        end

        def argument_series_contains?(actual_argument_series, expected_argument_series)
          ensure_wildcards_match(actual_argument_series, expected_argument_series)
          expected_argument_series.empty? or
              actual_argument_series.each_cons(expected_argument_series.size).include? expected_argument_series
        end
        
        def ensure_wildcards_match(actual_argument_series, expected_argument_series)
          # yes, i know. i am disappointed in myself
          num_of_args = actual_argument_series.size
          expected_argument_series.zip((0..num_of_args), actual_argument_series) do |expected_arg, index, actual_arg|
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
end
