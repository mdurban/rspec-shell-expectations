require 'spec_helper'
include Rspec::Bash

describe('StubbedEnv override tests') do
  subject { create_stubbed_env }
  let(:stubbed_env) { subject }

  let!(:command) do
    command = subject.stub_command('overridden_command')
    command.outputs('i was overridden')
    command.outputs('standard error output', to: :stderr)
    command
  end
  let!(:function) do
    function = subject.stub_command('overridden_function')
    function.outputs('i was overridden')
    function.outputs('standard error output', to: :stderr)
    function
  end

  context '#execute_inline' do
    context 'with a stubbed function' do
      context 'and no arguments' do
        execute_script(
          <<-multiline_script
            #!/usr/bin/env bash
            function overridden_function {
              echo 'i was not overridden'
            }
            overridden_function

            echo 'standard error output' 1>&2
          multiline_script
        )

        it 'calls the stubbed function' do
          expect(function).to be_called
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(stderr.chomp).to eql('standard error outputstandard error output')
        end
      end

      context 'and simple arguments' do
        execute_script(
          <<-multiline_script
            #!/usr/bin/env bash
              function overridden_function {
                echo 'i was not overridden'
              }
              overridden_function argument_one argument_two

              echo 'standard error output' 1>&2
        multiline_script
        )

        it 'calls the stubbed function' do
          expect(function).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        execute_script(
          <<-multiline_script
            #!/usr/bin/env bash
              function overridden_function {
                echo 'i was not overridden'
              }
              overridden_function "argument one" "argument two"

              echo 'standard error output' 1>&2
        multiline_script
        )

        it 'calls the stubbed function' do
          expect(function).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end
    end
    context 'with a stubbed command' do
      context 'and no arguments' do
        execute_script(
          <<-multiline_script
              #!/usr/bin/env bash
              overridden_command
          multiline_script
        )

        it 'calls the stubbed command' do
          expect(command).to be_called
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and simple arguments' do
        execute_script(
          <<-multiline_script
              #!/usr/bin/env bash
              overridden_command argument_one argument_two
          multiline_script
        )

        it 'calls the stubbed command' do
          expect(command).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        execute_script(
          <<-multiline_script
              #!/usr/bin/env bash
              overridden_command "argument one" "argument two"
        multiline_script
        )

        it 'calls the stubbed command' do
          expect(command).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and a path' do
        context 'relative path' do
          let!(:path_command) do
            path_command = subject.stub_command('relative/path/to/overridden_path_command')
            path_command.outputs('i was overridden in a path')
          end

          execute_script(
            'relative/path/to/overridden_path_command'
          )

          it 'calls the relative path stubbed command' do
            expect(path_command).to be_called
          end

          it 'prints the relative path overridden output' do
            expect(stdout).to eql('i was overridden in a path')
          end
        end
        context 'absolute path' do
          let!(:path_command) do
            path_command = subject.stub_command('/absolute/path/to/overridden_path_command')
            path_command.outputs('i was overridden in a path')
          end

          execute_script(
            '/absolute/path/to/overridden_path_command'
          )

          it 'calls the stubbed command' do
            expect(path_command).to be_called
          end

          it 'prints the overridden output' do
            expect(stdout).to eql('i was overridden in a path')
          end
        end
      end
    end
  end

  context '#execute_function' do
    context 'with a stubbed function' do
      context 'and no arguments' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_function'
        )

        it 'calls the stubbed function' do
          expect(function).to be_called
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(stderr).to eql("standard error output\n")
        end
      end

      context 'and simple arguments' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_function argument_one argument_two'
        )

        it 'calls the stubbed function' do
          expect(function).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_function "argument one" "argument two"'
        )

        it 'calls the stubbed function' do
          expect(function).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and a path' do
        context 'relative path' do
          let!(:path_function) do
            path_function = subject.stub_command('relative/path/to/overridden_path_functions')
            path_function.outputs('i was overridden in a path')
          end

          execute_function(
            './spec/scripts/function_library.sh',
            'relative/path/to/overridden_path_functions'
          )

          it 'calls the relative path stubbed function' do
            expect(path_function).to be_called
          end

          it 'prints the relative path overridden output' do
            expect(stdout).to eql('i was overridden in a path')
          end
        end
        context 'absolute path' do
          let!(:path_function) do
            path_function = subject.stub_command('/absolute/path/to/overridden_path_functions')
            path_function.outputs('i was overridden in a path')
          end

          execute_function(
            './spec/scripts/function_library.sh',
            '/absolute/path/to/overridden_path_functions'
          )

          it 'calls the stubbed function' do
            expect(path_function).to be_called
          end

          it 'prints the overridden output' do
            expect(stdout).to eql('i was overridden in a path')
          end
        end
      end
    end
    context 'with a stubbed command' do
      context 'and no arguments' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_command_function'
        )

        it 'calls the stubbed command' do
          expect(command).to be_called
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end

        it 'prints provided stderr output to standard error' do
          expect(stderr.chomp).to eql('standard error outputstandard error output')
        end
      end

      context 'and simple arguments' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_command_function argument_one argument_two'
        )

        it 'calls the stubbed command' do
          expect(command).to be_called_with_arguments('argument_one', 'argument_two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end

      context 'and complex arguments (spaces, etc.)' do
        execute_function(
          './spec/scripts/function_library.sh',
          'overridden_command_function "argument one" "argument two"'
        )

        it 'calls the stubbed command' do
          expect(command).to be_called_with_arguments('argument one', 'argument two')
        end

        it 'prints the overridden output' do
          expect(stdout).to eql('i was overridden')
        end
      end
    end
  end
end
