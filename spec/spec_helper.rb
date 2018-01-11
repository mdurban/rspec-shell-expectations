require 'simplecov'
SimpleCov.start

require 'English'
require 'rspec/bash'
require 'socket'
require 'sparsify'
require 'tempfile'
require 'yaml'

require 'helper/string_file_io'
require 'helper/shared_tmpdir'

RSpec.configure do |c|
  c.include Rspec::Bash
end

def execute_script(script)
  let!(:execute_results) do
    stdout, stderr, status = stubbed_env.execute_inline(
      script
    )
    [stdout, stderr, status]
  end
  let(:stdout) { execute_results[0] }
  let(:stderr) { execute_results[1] }
  let(:exitcode) { execute_results[2].exitstatus }
end

def execute_function(script, function)
  let!(:execute_results) do
    stdout, stderr, status = stubbed_env.execute_function(
      script,
      function
    )
    [stdout, stderr, status]
  end
  let(:stdout) { execute_results[0] }
  let(:stderr) { execute_results[1] }
  let(:exitcode) { execute_results[2].exitstatus }
end
