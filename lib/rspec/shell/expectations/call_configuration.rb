require 'yaml'

module Rspec
  module Shell
    module Expectations
      # Configuration of a stubbed command
      class CallConfiguration
        attr_reader :command

        def initialize(config_path, command)
          @config_path = config_path
          @configuration = {}
          @command = command
        end

        def set_exitcode(statuscode, args = [])
          @configuration[args] ||= {}
          @configuration[args][:statuscode] = statuscode
        end

        def set_output(content, target, args = [])
          @configuration[args] ||= {}
          @configuration[args][:outputs] ||= []
          @configuration[args][:outputs] << { target: target, content: content }
        end

        def write
          structure = @configuration.map do |args, results|
            call = {
              args: args
            }.merge results
          end

          @config_path.open('w') do |f|
            f.puts structure.to_yaml
          end
        end
      end
    end
  end
end
