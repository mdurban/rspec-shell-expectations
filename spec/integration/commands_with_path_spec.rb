require 'English'
require 'rspec/bash'

describe 'scenario where command with path is mocked' do
  include Rspec::Bash

  context 'execute_inline' do
    let(:stubbed_env) { create_stubbed_env }
    let!(:absolute_path_mock) { stubbed_env.stub_command('/absolute/path/to/command') }
    let!(:relative_path_mock) { stubbed_env.stub_command('relative/path/to/other/command2') }

    it 'calls absolute path mock' do
      stubbed_env.execute_inline('/absolute/path/to/command')

      expect(absolute_path_mock).to be_called
    end

    it 'calls relative path mock' do
      stubbed_env.execute_inline('relative/path/to/other/command2')

      expect(relative_path_mock).to be_called
    end
  end

  context 'execute in-memory script' do
    let(:script) do
      <<-SCRIPT
      arbitrary_command
      /absolute/path/to/command
      relative/path/to/command2
      SCRIPT
    end
    let(:script_path) { Pathname.new '/tmp/test_script.sh' }

    before do
      script_path.open('w') { |f| f.puts script }
      script_path.chmod 0777
    end

    after do
      script_path.delete
    end

    let(:stubbed_env) { create_stubbed_env }
    let!(:arbitrary_command_mock) { stubbed_env.stub_command('arbitrary_command') }
    let!(:absolute_path_mock) { stubbed_env.stub_command('/absolute/path/to/command') }
    let!(:relative_path_mock) { stubbed_env.stub_command('relative/path/to/command2') }

    it 'regular command is mocked' do
      stubbed_env.execute(script_path)

      expect(arbitrary_command_mock).to be_called
    end

    it 'absolute path command is mocked' do
      stubbed_env.execute(script_path)

      expect(absolute_path_mock).to be_called
    end

    it 'relative path command is mocked' do
      stubbed_env.execute(script_path)

      expect(relative_path_mock).to be_called
    end
  end
end
