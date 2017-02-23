module Rspec
  module Bash
    class StubbedCommand
      attr_reader :call_log, :arguments, :path

      def initialize(command, dir)
        @path = create_stub_file(command, dir)
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
        @call_log.exist? && @call_log.called_with_args?(*@args)
      end

      def called_with_no_args?
        @call_log.called_with_no_args?
      end

      def called_with_args?(*args)
        @call_log.called_with_args?(*args)
      end

      def call_count(*arg)
        @call_log.call_count(*arg)
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

      def create_stub_file(command_name, directory)
        command_path = File.join(directory, command_name)
        stub_template_path = File.expand_path(
          'stub.rb.erb',
          "#{File.dirname(__FILE__)}/../../../bin"
        )
        template = ERB.new File.read(stub_template_path), nil, '%'
        stub_content = template.result(binding)
        File.open(command_path, 'w') { |file| file.write(stub_content) }
        File.chmod(0755, command_path)

        command_path
      end

      def stub_filepath
        project_root.join('bin', 'stub')
      end

      def project_root
        Pathname.new(File.dirname(File.expand_path(__FILE__))).join('..', '..', '..')
      end
    end
  end
end
