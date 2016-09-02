module Rspec
  module Shell
    module Expectations
      class StubbedCommand
        attr_reader :call_log, :arguments

        def initialize(command, dir)
          command_path = File.join(dir, command)
          FileUtils.cp(stub_filepath, command_path)
          @arguments = []
          @call_configuration = CallConfiguration.new(
              Pathname.new(dir).join("#{command}_stub.yml"),
              command
          )
          @call_log = CallLog.new(
              Pathname.new(dir).join("#{command}_calls.yml")
          )
        end

        def with_args(*args)
          @arguments = args
          self
        end

        def called?
          @call_log.exist? and @call_log.called_with_args?(*@args)
        end

        def called_with_no_args?
            @call_log.called_with_no_args?
        end

        def called_with_args?(*args, position: false)
          @call_log.called_with_args?(*args, position: position)
        end
        
        def get_argument_count(*arg)
          @call_log.get_argument_count(*arg)
        end

        def returns_exitstatus(statuscode)
          @call_configuration.set_exitcode(statuscode, @arguments)
          @call_configuration.write
          self
        end

        def stdin
          @call_log.stdin_for_args(*@arguments) if @call_log.exist?
        end

        def outputs(contents, to: :stdout)
          @call_configuration.set_output(contents, to, @arguments)
          @call_configuration.write
          self
        end

        def inspect
          if @arguments.any?
            "<Stubbed #{@call_configuration.command.inspect} " \
              "args: #{@arguments.join(' ').inspect}>"
          else
            "<Stubbed #{@call_configuration.command.inspect}>"
          end
        end

        private

        def stub_filepath
          project_root.join('bin', 'stub')
        end

        def project_root
          Pathname.new(File.dirname(File.expand_path(__FILE__)))
              .join('..', '..', '..', '..')
        end
      end
    end
  end
end
