require 'spec_helper'
include Rspec::Bash

describe 'StubbedEnv' do
  subject { StubbedEnv.new(StubbedEnv::RUBY_STUB) }
  let(:server_thread) { double(Thread) }
  let(:server_port) { 4000 }
  let!(:tcp_server) do
    tcp_server = double(TCPServer)
    allow(tcp_server).to receive(:addr)
      .and_return(['ADDR', server_port])
    allow(TCPServer).to receive(:new)
      .with('localhost', 0)
      .and_return(tcp_server)
    tcp_server
  end
  let!(:log_manager) do
    log_manager = double(CallLogManager)
    allow(CallLogManager).to receive(:new)
      .and_return(log_manager)
    log_manager
  end
  let!(:conf_manager) do
    conf_manager = double(CallConfigurationManager)
    allow(CallConfigurationManager).to receive(:new)
      .and_return(conf_manager)
    conf_manager
  end
  let!(:stub_marshaller) do
    stub_marshaller = double(RubyStubMarshaller)
    allow(RubyStubMarshaller).to receive(:new)
      .and_return(stub_marshaller)
    stub_marshaller
  end
  let!(:stub_server) do
    stub_server = double(StubServer)
    allow(stub_server).to receive(:start)
      .and_return(server_thread)
    allow(StubServer).to receive(:new)
      .with(log_manager, conf_manager, stub_marshaller)
      .and_return(stub_server)
    stub_server
  end
  let!(:stub_wrapper) do
    stub_wrapper = double(BashWrapper)
    allow(BashWrapper).to receive(:new)
      .and_return(stub_wrapper)
    allow(stub_wrapper).to receive(:add_override)
    stub_wrapper
  end

  context '#initialize' do
    it 'creates and starts a StubServer' do
      allow(server_thread).to receive(:kill)

      expect(StubServer).to receive(:new)
        .with(log_manager, conf_manager, stub_marshaller)
        .and_return(stub_server)

      expect(stub_server).to receive(:start)
        .with(tcp_server)

      StubbedEnv.new(StubbedEnv::RUBY_STUB)
    end
  end
  context '#stub_command' do
    let!(:stub_command) do
      stub_command = double(StubbedCommand)
      allow(StubbedCommand).to receive(:new)
        .and_return(stub_command)
      stub_command
    end
    before do
      stub_function = double(StubFunction)

      allow(stub_function).to receive(:script)
        .with('first_command')
        .and_return('first_command override')
      allow(stub_function).to receive(:script)
        .with('second_command')
        .and_return('second_command override')

      allow(StubFunction).to receive(:new)
        .and_return(stub_function)
    end

    it 'adds the call conf and log managers to the command' do
      expect(StubbedCommand).to receive(:new)
        .with('first_command', log_manager, conf_manager)

      command = subject.stub_command('first_command')
      expect(command).to equal(stub_command)
    end
    it 'adds the function override for the command to the wrapper' do
      expect(stub_wrapper).to receive(:add_override)
        .with('first_command override')
      expect(stub_wrapper).to receive(:add_override)
        .with('second_command override')

      subject.stub_command('first_command')
      subject.stub_command('second_command')
    end
    disallowed_commands = %w(command function)
    disallowed_commands.each do |command|
      it "does not allow #{command}" do
        expect { subject.stub_command(command) }.to raise_error(
          "Not able to stub command #{command}. Reserved for use by test wrapper."
        )
      end
    end
  end
  context '#execute' do
    it 'wraps the file to execute and sends it to Open3' do
      allow(stub_wrapper).to receive(:wrap_script)
        .with('command source file_to_execute')
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')

      subject.execute('file_to_execute', 'DOG' => 'cat')
    end
  end
  context('#execute_function') do
    it 'wraps the file to execute and sends it to Open3' do
      allow(stub_wrapper).to receive(:wrap_script)
        .with("command source file_to_execute\nfunction_to_execute")
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')

      subject.execute_function('file_to_execute', 'function_to_execute', 'DOG' => 'cat')
    end
  end
  context '#execute_inline' do
    before do
      tempfile = double(Tempfile)
      allow(tempfile).to receive(:path)
        .and_return('file_to_execute')
      allow(Tempfile).to receive(:new)
        .with('inline-')
        .and_return(tempfile)
      allow(stub_wrapper).to receive(:wrap_script)
      allow(Open3).to receive(:capture3)
    end
    it 'puts the inline script into a file' do
      expect(File).to receive(:write)
        .with('file_to_execute', 'inline script to execute')
      expect(File).to receive(:delete)
        .with('file_to_execute')
      subject.execute_inline('inline script to execute', 'DOG' => 'cat')
    end
    it 'wraps the file to execute and sends it to Open3' do
      allow(stub_wrapper).to receive(:wrap_script)
        .with('command source file_to_execute')
        .and_return('wrapped script')
      expect(Open3).to receive(:capture3)
        .with({ 'DOG' => 'cat' }, 'wrapped script')
      subject.execute_inline('inline script to execute', 'DOG' => 'cat')
    end
  end
end
