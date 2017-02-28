require 'English'
require 'rspec/bash'

describe 'commands in path' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  let!(:absolute_path_mock) { stubbed_env.stub_command('/absolute/path/to/command') }
  let!(:relative_path_mock) { stubbed_env.stub_command('relative/path/to/other/command') }
  let!(:a) { stubbed_env.stub_command('ls') }

  it 'does not call the grep command' do
    stubbed_env.execute_inline('/absolute/path/to/command')

    expect(absolute_path_mock).to be_called
  end

  it 'does not call the ls command' do
    stubbed_env.execute_inline('relative/path/to/other/command')

    expect(relative_path_mock).to be_called
  end

  it 'does not call the ls command' do
    stubbed_env.execute_inline('ls')

    expect(a).to be_called
  end
end
