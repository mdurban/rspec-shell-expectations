require 'English'
require 'rspec/bash'

# TODO - the below specs test implementation, until the goofy wiring of StubbedCommand => StubbedCall => CallLog is sorted out

describe 'be_called_with_arguments' do
  include Rspec::Bash
  let(:stubbed_env) { create_stubbed_env }

  context 'with a command' do
    context 'and no chain calls' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command first_argument second_argument
        multiline_script
        )
      end
      it 'correctly identifies the called arguments' do
        expect(@command).to be_called_with_arguments('first_argument', 'second_argument')
      end
      it 'correctly matches when wildcard is used for first argument' do
        expect(@command).to be_called_with_arguments(anything, 'second_argument')
      end
      it 'correctly matches when wildcard is used for second argument' do
        expect(@command).to be_called_with_arguments('first_argument', anything)
      end
      it 'correctly matches when wildcard is used for all arguments' do
        expect(@command).to be_called_with_arguments(anything, anything)
      end
    end
    context 'and the times chain call' do
      before(:each) do
        @command = stubbed_env.stub_command('stubbed_command')
        @actual_stdout, @actual_stderr, @actual_status = stubbed_env.execute_inline(<<-multiline_script
          stubbed_command duplicated_argument once_called_argument
          stubbed_command duplicated_argument irrelevant_argument
        multiline_script
        )
      end
      it 'matches when arguments are called twice' do
        expect(@command).to be_called_with_arguments('duplicated_argument', anything).times(2)
      end
      it 'matches when argument is called once' do
        expect(@command).to be_called_with_arguments(anything, 'once_called_argument').times(1)
      end
      it 'matches when argument combination is called once' do
        expect(@command).to be_called_with_arguments('duplicated_argument', 'once_called_argument').times(1)
      end
      it 'matches when argument is not called' do
        expect(@command).to_not be_called_with_arguments('not_called_argument').times(1)
      end
    end
  end

  context 'when matcher fails' do
    before(:each) do
      @command = stubbed_env.stub_command('stubbed_command')
      stubbed_env.execute_inline(<<-multiline_script
        stubbed_command no_match_arg1 no_match_arg2 no_match_arg3 no_match_arg4
      multiline_script
      )
    end
    it 'should tell me why' do
      expect(@command).to be_called_with_arguments('bacon, potato')
    end
    it 'should fail when one argument is missing' do
      expect(@command).to be_called_with_arguments('no_match_arg1 no_match_arg2 no_match_arg3')
    end
    it 'should fail when all arguments are there but in incorrect order' do
      expect(@command).to be_called_with_arguments('no_match_arg4 no_match_arg2 no_match_arg3 no_match_arg1')
    end
    it 'should fail when there are extra arguments' do
      expect(@command).to be_called_with_arguments('no_match_arg1 no_match_arg2 no_match_arg3 no_match_arg4, no_match_arg99'), "hello"
    end
  end

end
