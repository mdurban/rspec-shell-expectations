require 'English'
require 'rspec/bash'

describe 'very simple script that just exits' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }
  it 'returns an exit status of 0' do
    out, err, rv = stubbed_env.execute_inline('exit 0')

    expect(out).to eql ''
    expect(err).to eql ''
    expect(rv.exitstatus).to eql 0
  end
end
