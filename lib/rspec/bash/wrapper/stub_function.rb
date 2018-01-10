module Rspec
  module Bash
    class StubFunction
      def initialize(port, stub_script_class)
        @port = port
        @stub_script_class = stub_script_class
      end

      def header(name)
        "function #{name} {"
      end

      def footer(name)
        "}\ncommand readonly -f #{name} &> /dev/null"
      end

      def body(name)
        "#{stub_path} #{name} #{@port} \"${@}\""
      end

      def script(name)
        <<-multiline_string
        #{header(name)}
        #{body(name)}
        #{footer(name)}
        multiline_string
      end

      private

      def stub_path
        @stub_script_class.path
      end
    end
  end
end
