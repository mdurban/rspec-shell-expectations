require 'spec_helper'
include Rspec::Bash

describe 'RubyStubFunction' do
  let(:subject_path) { RubyStubScript.path }

  let(:stub_output_string_pathname) { instance_double(Pathname) }
  let(:stub_output_string_file) { StringIO.new }
  let(:stub_stderr_file) { StringIO.new }
  let(:stub_stdout_file) { StringIO.new }
  let(:stub_exit_code_list) { [] }

  let(:stub_socket) { StringFileIO.new }

  def safe_load_subject
    load subject_path
  rescue SystemExit
  end

  before(:each) do
    $stderr = stub_stderr_file
    $stdout = stub_stdout_file
    allow($stdin).to receive(:tty?).and_return(false)

    allow_any_instance_of(Kernel).to receive(:exit) do |_, exit_code|
      stub_exit_code_list << exit_code
      raise SystemExit
    end

    allow(stub_socket).to receive(:close_write)
    allow(stub_socket).to receive(:close_read)
    allow(TCPSocket).to receive(:new).and_return(stub_socket)
    allow(Pathname).to receive(:new).with('tofile')
      .and_return(stub_output_string_pathname)
    allow(stub_output_string_pathname).to receive(:open).with('w')
      .and_yield(stub_output_string_file)
  end

  context 'with no configuration (logging only)' do
    let!(:call_log_list) { [] }
    before do
      allow(stub_socket).to receive(:read).and_return(Marshal.dump({}))
      expect(TCPSocket).to receive(:new).exactly(4)
        .with('localhost', 55_555)
        .and_return(stub_socket)

      ARGV.replace ['first_command', 55_555]
      allow($stdin).to receive(:read).and_return('')
      safe_load_subject
      call_log_list << Marshal.load(stub_socket.string)

      ARGV.replace ['first_command', 55_555]
      allow($stdin).to receive(:read).and_return("dog\ncat\n")
      safe_load_subject
      call_log_list << Marshal.load(stub_socket.string)

      ARGV.replace ['first_command', 55_555, 'first_argument', 'second_argument']
      allow($stdin).to receive(:read).and_return('')
      safe_load_subject
      call_log_list << Marshal.load(stub_socket.string)

      ARGV.replace ['first_command', 55_555, 'first_argument', 'second_argument']
      allow($stdin).to receive(:read).and_return("dog\ncat\n")
      safe_load_subject
      call_log_list << Marshal.load(stub_socket.string)
    end

    it 'logs the correct command for the first call' do
      expect(call_log_list[0][:command]).to eql 'first_command'
    end

    it 'logs a blank STDIN for the first call' do
      expect(call_log_list[0][:stdin]).to eql ''
    end

    it 'logs no arguments for the first call' do
      expect(call_log_list[0][:args]).to be_empty
    end

    it 'logs the correct command for the second call' do
      expect(call_log_list[1][:command]).to eql 'first_command'
    end

    it 'logs some STDIN for the second call' do
      expect(call_log_list[1][:stdin]).to eql "dog\ncat\n"
    end

    it 'logs no arguments for the second call' do
      expect(call_log_list[1][:args]).to be_empty
    end

    it 'logs the correct command for the third call' do
      expect(call_log_list[2][:command]).to eql 'first_command'
    end

    it 'logs a blank STDIN for the third call' do
      expect(call_log_list[2][:stdin]).to be_empty
    end

    it 'logs some arguments for the third call' do
      expect(call_log_list[2][:args]).to eql %w(first_argument second_argument)
    end

    it 'logs the correct command for the fourth call' do
      expect(call_log_list[3][:command]).to eql 'first_command'
    end

    it 'logs some STDIN for the fourth call' do
      expect(call_log_list[3][:stdin]).to eql "dog\ncat\n"
    end

    it 'logs some arguments for the fourth call' do
      expect(call_log_list[3][:args]).to eql %w(first_argument second_argument)
    end

    it 'exits with appropriate code for first call' do
      expect(stub_exit_code_list[0]).to eql 0
    end

    it 'exits with appropriate code for second call' do
      expect(stub_exit_code_list[1]).to eql 0
    end

    it 'exits with appropriate code for third call' do
      expect(stub_exit_code_list[2]).to eql 0
    end

    it 'exits with appropriate code for fourth call' do
      expect(stub_exit_code_list[3]).to eql 0
    end
  end
  context 'with some configuration (logging and output)' do
    before do
      stdout_configuration = {
        args: [],
        outputs: {
          stderr: {
            target: :stderr,
            content: "stderr\n"
          },
          stdout: {
            target: :stdout,
            content: "stdout\n"
          },
          'tofile' => {
            target: 'tofile',
            content: "tofile\n"
          }
        },
        exitcode: 8
      }
      allow(stub_socket).to receive(:read).and_return(Marshal.dump(stdout_configuration))
      allow($stdin).to receive(:read).and_return('')

      ARGV.replace ['first_command', 55_555]
      safe_load_subject

      ARGV.replace ['first_command', 55_555, 'first_argument', 'second_argument']
      safe_load_subject

      ARGV.replace ['first_command', 55_555, 'first_argument', 'second_argument', 'third_argument']
      safe_load_subject

      ARGV.replace [
        'first_command',
        55_555,
        'first_argument',
        'second_argument',
        'third_argument',
        'fourth_argument'
      ]

      safe_load_subject
    end

    it 'prints the expected output to stderr' do
      expect(stub_stderr_file.string).to eql "stderr\nstderr\nstderr\nstderr\n"
    end

    it 'prints the expected output to stdout' do
      expect(stub_stdout_file.string).to eql "stdout\nstdout\nstdout\nstdout\n"
    end

    it 'prints the expected output to the string named file' do
      expect(stub_output_string_file.string).to eql "tofile\ntofile\ntofile\ntofile\n"
    end

    it 'exits with appropriate code for first call' do
      expect(stub_exit_code_list[0]).to eql 8
    end

    it 'exits with appropriate code for second call' do
      expect(stub_exit_code_list[1]).to eql 8
    end

    it 'exits with appropriate code for third call' do
      expect(stub_exit_code_list[2]).to eql 8
    end

    it 'exits with appropriate code for fourth call' do
      expect(stub_exit_code_list[3]).to eql 8
    end
  end
end
