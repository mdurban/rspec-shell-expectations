require 'tmpdir'
require 'English'
require 'open3'
require 'tempfile'

module Rspec
  module Bash
    def create_stubbed_env(stub_type =
      ENV.fetch('RSPEC_BASH_STUB_TYPE', StubbedEnv::BASH_STUB).to_sym)

      StubbedEnv.new(stub_type)
    end

    class StubbedEnv
      RUBY_STUB = :ruby_stub
      BASH_STUB = :bash_stub

      def initialize(stub_type)
        start_stub_server(stub_type)
      end

      def start_stub_server(stub_type)
        tcp_server = create_tcp_server
        stub_server = create_stub_server(stub_type)
        stub_server.start(tcp_server)
      end

      def stub_command(command)
        check_if_command_is_allowed(command)
        add_override_for_command(command)
        create_stubbed_command(command)
      end

      def execute(command, env_vars = {})
        script_runner = "command source #{command}"
        script_wrapper = wrap_script(script_runner)
        execute_script(env_vars, script_wrapper)
      end

      def execute_function(script, command, env_vars = {})
        script_runner = "command source #{script}\n#{command}"
        script_wrapper = wrap_script(script_runner)
        execute_script(env_vars, script_wrapper)
      end

      def execute_inline(command_string, env_vars = {})
        temp_command_file = Tempfile.new('inline-')
        temp_command_path = temp_command_file.path
        write_file(temp_command_path, command_string)
        stdout, stderr, status = execute(temp_command_path, env_vars)
        delete_file(temp_command_path)
        [stdout, stderr, status]
      end

      private

      STUB_MARSHALLER_MAPPINGS = {
        RUBY_STUB => RubyStubMarshaller,
        BASH_STUB => BashStubMarshaller
      }.freeze
      STUB_SCRIPT_MAPPINGS = {
        RUBY_STUB => RubyStubScript,
        BASH_STUB => BashStubScript
      }.freeze
      DISALLOWED_COMMANDS = %w(command function).freeze

      def create_tcp_server
        tcp_server = TCPServer.new('localhost', 0)
        @stub_server_port = tcp_server.addr[1]
        tcp_server
      end

      def create_stub_server(stub_type)
        stub_marshaller = STUB_MARSHALLER_MAPPINGS[stub_type].new
        stub_script_class = STUB_SCRIPT_MAPPINGS[stub_type]
        @stub_wrapper = BashWrapper.new(@stub_server_port)
        @stub_function = StubFunction.new(@stub_server_port, stub_script_class)
        @call_log_manager = CallLogManager.new
        @call_conf_manager = CallConfigurationManager.new
        StubServer.new(@call_log_manager, @call_conf_manager, stub_marshaller)
      end

      def create_stubbed_command(command)
        StubbedCommand.new(
          command,
          @call_log_manager,
          @call_conf_manager
        )
      end

      def execute_script(env_vars, script)
        Open3.capture3(env_vars, script)
      end

      def wrap_script(script)
        @stub_wrapper.wrap_script(script)
      end

      def delete_file(file_path)
        File.delete(file_path)
      end

      def write_file(file_path, contents)
        File.write(file_path, contents)
      end

      def check_if_command_is_allowed(command)
        error_message = "Not able to stub command #{command}. Reserved for use by test wrapper."

        raise(error_message) if DISALLOWED_COMMANDS.include? command
      end

      def add_override_for_command(command)
        function_override = @stub_function.script(command).chomp
        @stub_wrapper.add_override(function_override)
      end
    end
  end
end
