require 'spec_helper'
include Rspec::Bash

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def expect_normal_operation
  it 'should not blow up the test framework' do
    expect(first_command).to be_called_with_arguments('hello')
  end

  it 'should return given stdout' do
    expect(stdout).to eql 'stdout'
  end

  it 'should return given stderr' do
    expect(stderr.chomp).to eql 'stderr'
  end

  it 'should return the given exit code' do
    expect(exitcode).to eql 1
  end

  it 'treat calls like any other stub' do
    expect(second_command).to be_called_with_no_arguments
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/AbcSize

describe 'integration for overrides of key stub internals' do
  let(:stubbed_env) { create_stubbed_env }
  let!(:first_command) do
    stubbed_env.stub_command('first_command')
               .outputs('stdout', to: :stdout)
               .outputs('stderr', to: :stderr)
               .returns_exitstatus(1)
  end

  context 'bash' do
    let!(:second_command) { stubbed_env.stub_command('bash') }

    execute_script 'bash; first_command hello'

    expect_normal_operation
  end

  context 'ruby' do
    let!(:second_command) { stubbed_env.stub_command('ruby') }

    execute_script 'ruby; first_command hello'

    expect_normal_operation
  end

  context '/usr/bin/env' do
    let!(:second_command) { stubbed_env.stub_command('/usr/bin/env') }

    execute_script '/usr/bin/env; first_command hello'

    expect_normal_operation
  end

  context 'source' do
    let!(:second_command) { stubbed_env.stub_command('source') }

    execute_script 'source; first_command hello'

    expect_normal_operation
  end

  context 'grep' do
    let!(:second_command) { stubbed_env.stub_command('grep') }

    execute_script 'grep; first_command hello'

    expect_normal_operation
  end

  context 'exit' do
    let!(:second_command) { stubbed_env.stub_command('exit') }

    execute_script 'exit; first_command hello'

    expect_normal_operation
  end

  context 'readonly' do
    let!(:second_command) { stubbed_env.stub_command('readonly') }

    execute_script <<-multiline_script
      function first_command {
        echo 'overridden'
      }

      readonly
      first_command hello
    multiline_script

    expect_normal_operation
  end
end
