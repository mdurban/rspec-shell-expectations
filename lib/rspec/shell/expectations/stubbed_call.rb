module Rspec
  module Shell
    module Expectations
      # A specific call with arguments on a StubbedCommand
      class StubbedCall
        attr_reader :call_log

        def initialize(config, call_log, args)
          @config = config
          @call_log = call_log
          @args = args
        end

        def with_args(*args)
          StubbedCall.new(@config, @call_log, @args + args)
        end

        def returns_exitstatus(statuscode)
          @config.set_exitcode(statuscode, @args)
          @config.write
          self
        end

        def outputs(content, to: :stdout)
          @config.set_output(content, to, @args)
          @config.write
          self
        end

        def stdin
          return nil unless @call_log.exist?
          @call_log.stdin_for_args(*@args)
        end
        
        def called?
          return false unless @call_log.exist?
          @call_log.called_with_args?(*@args)
        end

        def called_with_args?(*args, position: false)
          @call_log.called_with_args?(*args, sub_command_series: @args, position: position)
        end

        def get_argument_count(*arg)
          @call_log.get_argument_count(*arg)
        end

        def inspect
          if @args.any?
            "<Stubbed #{@config.command.inspect} " \
              "args: #{@args.join(' ').inspect}>"
          else
            "<Stubbed #{@config.command.inspect}>"
          end
        end
      end
    end
  end
end
