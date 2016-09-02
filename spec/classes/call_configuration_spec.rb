require 'rspec/shell/expectations'

describe 'CallConfiguration' do
  let(:stubbed_env) { create_stubbed_env }
  include Rspec::Shell::Expectations

  context '#set_exitcode' do
    it 'returns the status code that is provided' do
      @subject = Rspec::Shell::Expectations::CallConfiguration.new(anything, anything)

      expect(@subject.set_exitcode('status')).to eql 'status'
    end
  end
  context '#write' do
      it 'raises error when there is no config_path' do
      @subject = Rspec::Shell::Expectations::CallConfiguration.new(nil, anything)

      expect { @subject.write }.to raise_exception(NoMethodError)
    end
  end
end
