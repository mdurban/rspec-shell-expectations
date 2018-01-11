require 'spec_helper'
include Rspec::Bash

describe 'StubbedCommand' do
  let(:stubbed_env) { create_stubbed_env }
  let!(:command) { stubbed_env.stub_command('stubbed_command') }

  context '#returns_exitstatus' do
    context 'when given no exit status to return' do
      execute_script('stubbed_command first_argument second_argument')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 0
      end
    end

    context 'when given no args to match' do
      before do
        command
          .returns_exitstatus(100)
      end

      execute_script('stubbed_command first_argument second_argument')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 100
      end
    end

    context 'when given an exact argument match' do
      before do
        command
          .with_args('first_argument', 'second_argument')
          .returns_exitstatus(101)
      end

      execute_script('stubbed_command first_argument second_argument')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 101
      end
    end
    context 'when given an anything argument match' do
      before do
        command
          .with_args('first_argument', anything)
          .returns_exitstatus(102)
      end

      execute_script('stubbed_command first_argument second_argument')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 102
      end
    end
    context 'when given any_args argument match' do
      before do
        command
          .with_args(any_args)
          .returns_exitstatus(103)
      end

      execute_script('stubbed_command poglet piglet')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 103
      end
    end
    context 'when given other types of RSpec::Mock::ArgumentMatcher argument match' do
      before do
        command
          .with_args(instance_of(String), instance_of(String))
          .returns_exitstatus(104)
      end

      execute_script('stubbed_command poglet 1')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 104
      end
    end
    context 'when given regex argument match' do
      before do
        command
          .with_args(/p.glet/, /p.glet/)
          .returns_exitstatus(105)
      end

      execute_script('stubbed_command poglet piglet')

      it 'exits with the appropriate exit code' do
        expect(exitcode).to be 105
      end
    end
  end
end
