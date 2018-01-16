require 'spec_helper'
include Rspec::Bash

describe 'StubbedCommand' do
  let(:stubbed_env) { create_stubbed_env }
  let!(:command) { stubbed_env.stub_command('stubbed_command') }

  describe '#outputs' do
    describe 'target stdout' do
      context 'when given no arguments to match' do
        before do
          command.outputs("\nhello\n", to: :stdout)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        before do
          command
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: :stdout)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql "\nhello\n"
        end
      end
      context 'when given an anything argument match' do
        before do
          command
            .with_args('first_argument', anything)
            .outputs('i respond to anything', to: :stdout)
        end

        execute_script('stubbed_command first_argument piglet')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql 'i respond to anything'
        end
      end
      context 'when given any_args argument match' do
        before do
          command
            .with_args(any_args)
            .outputs('i respond to any_args', to: :stdout)
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql 'i respond to any_args'
        end
      end
      context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
        before do
          command
            .with_args(instance_of(String), instance_of(String))
            .outputs('i respond to instance_of', to: :stdout)
        end

        execute_script('stubbed_command poglet 1')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql 'i respond to instance_of'
        end
      end
      context 'when given regex argument match' do
        before do
          command
            .with_args(/p.glet/, /p.glet/)
            .outputs('i respond to regex', to: :stdout)
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql 'i respond to regex'
        end
      end
    end

    # TODO: it is a bug that these require a \n in the output
    describe 'target stderr' do
      context 'when given no arguments to match' do
        before do
          command
            .outputs("\nhello\n", to: :stderr)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        before do
          command
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: :stderr)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "\nhello\n"
        end
      end
      context 'when given an anything argument match' do
        before do
          command
            .with_args('first_argument', anything)
            .outputs('i respond to anything', to: :stderr)
        end

        execute_script('stubbed_command first_argument piglet')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "i respond to anything\n"
        end
      end
      context 'when given any_args argument match' do
        before do
          command
            .with_args(any_args)
            .outputs('i respond to any_args', to: :stderr)
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "i respond to any_args\n"
        end
      end
      context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
        before do
          command
            .with_args(instance_of(String), instance_of(String))
            .outputs('i respond to instance_of', to: :stderr)
        end

        execute_script('stubbed_command poglet 1')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "i respond to instance_of\n"
        end
      end
      context 'when given regex argument match' do
        before do
          command
            .with_args(/p.glet/, /p.glet/)
            .outputs('i respond to regex', to: :stderr)
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected error to stderr' do
          expect(stderr).to eql "i respond to regex\n"
        end
      end
    end

    describe 'target file path' do
      let(:temp_file) { Tempfile.new('for testing') }

      context 'when given no arguments to match' do
        before do
          command
            .outputs("\nhello\n", to: temp_file.path)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql "\nhello\n"
        end
      end
      context 'when given an exact argument match' do
        before do
          command
            .with_args('first_argument', 'second_argument')
            .outputs("\nhello\n", to: temp_file.path)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql "\nhello\n"
        end
      end
      context 'when given an anything argument match' do
        before do
          command
            .with_args('first_argument', anything)
            .outputs('i respond to anything', to: temp_file.path)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql 'i respond to anything'
        end
      end
      context 'when given any_args argument match' do
        before do
          command
            .with_args(any_args)
            .outputs('i respond to any_args', to: temp_file.path)
        end

        execute_script('stubbed_command first_argument poglet')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql 'i respond to any_args'
        end
      end
      context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
        before do
          command
            .with_args(instance_of(String), instance_of(String))
            .outputs('i respond to instance_of', to: temp_file.path)
        end

        execute_script('stubbed_command poglet 1')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql 'i respond to instance_of'
        end
      end
      context 'when given regex argument match' do
        before do
          command
            .with_args(/p.glet/, /p.glet/)
            .outputs('i respond to regex', to: temp_file.path)
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected content to the file' do
          expect(temp_file.read).to eql 'i respond to regex'
        end
      end

      describe 'when given a passed argument for a filename' do
        let(:dynamic_file) { Pathname.new('output-piglet.txt') }

        before do
          command
            .outputs('i have a dynamic file name', to: ['output-', :arg2, '.txt'])
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected content to the file' do
          expect(dynamic_file.read).to eql 'i have a dynamic file name'
        end

        after(:each) do
          FileUtils.remove_entry_secure dynamic_file
        end
      end

      describe 'when given a filename that matches the stdout target' do
        let(:stdout_file) { Pathname.new('stdout') }

        before do
          command
            .outputs('i am supposed to go to a file', to: 'stdout')
        end

        execute_script('stubbed_command poglet piglet')

        it 'outputs the expected content to the file' do
          expect(stdout_file.read).to eql 'i am supposed to go to a file'
        end

        after(:each) do
          FileUtils.remove_entry_secure stdout_file
        end
      end
    end

    describe 'any target' do
      context 'when given a non-string output' do
        before do
          command.outputs(['an array'], to: :stdout)
        end

        execute_script('stubbed_command first_argument second_argument')

        it 'outputs the expected output to stdout' do
          expect(stdout).to eql '["an array"]'
        end
      end
    end
  end
end
