require 'yaml'

module Rspec
  module Bash
    class CallConfiguration
      attr_accessor :call_configuration

      def initialize
        @call_configuration = []
      end

      def set_exitcode(exitcode, args = [])
        current_conf = create_or_get_conf(args)
        current_conf[:exitcode] = exitcode
      end

      def add_output(content, target, args = [])
        current_conf = create_or_get_conf(args)
        type = determine_output_type(target)
        current_conf[:outputs] << {
          target: target,
          type: type,
          content: content.to_s
        }
      end

      def get_best_call_conf(args = [])
        call_conf_arg_matcher = Util::CallConfArgumentListMatcher.new(@call_configuration)
        best_call_conf = call_conf_arg_matcher.get_best_call_conf(args)
        remove_args_from_conf(
          interpolate_output_targets(
            best_call_conf,
            args
          )
        )
      end

      private

      def interpolate_output_targets(conf, args)
        return conf if conf.empty?
        conf[:outputs].each do |output|
          output[:target] = interpolate_target(output[:target], args)
        end
        conf
      end

      def interpolate_target(target, args)
        return target unless target.is_a? Array
        target.map do |target_element|
          next target_element if target_element.is_a? String
          interpolate_argument(target_element, args)
        end.join
      end

      def interpolate_argument(name, args)
        matching_arg_index = /^arg(\d+)$/.match(name.to_s)
        return name.to_s unless matching_arg_index
        args[matching_arg_index[1].to_i - 1]
      end

      def remove_args_from_conf(conf)
        conf.select { |key| ![:args].include?(key) }
      end

      def create_or_get_conf(args)
        new_conf = {
          args: args,
          exitcode: 0,
          outputs: []
        }
        current_conf = @call_configuration.select { |conf| conf[:args] == args }
        @call_configuration << new_conf if current_conf.empty?
        current_conf.first || new_conf
      end

      def determine_output_type(target)
        is_a_file_target = !([:stdout, :stderr].include? target)
        is_a_file_target ? :file : target
      end
    end
  end
end
