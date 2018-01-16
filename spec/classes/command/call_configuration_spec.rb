require 'spec_helper'
include Rspec::Bash

describe 'CallConfiguration' do
  subject { Rspec::Bash::CallConfiguration.new }

  context '#set_exitcode' do
    context 'with any setup' do
      context 'with no existing configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              exitcode: 1,
              outputs: []
            }
          ]
        end

        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
      context 'with an existing, non-matching configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument),
              exitcode: 1,
              outputs: []
            },
            {

              args: %w(first_argument second_argument),
              exitcode: 1,
              outputs: []
            }
          ]
        end
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument),
              exitcode: 1,
              outputs: []
            }
          ]
        end
        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
      context 'with an existing, matching configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              exitcode: 1,
              outputs: []
            }
          ]
        end
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument second_argument),
              exitcode: 2,
              outputs: []
            }
          ]
        end

        it 'updates the status code conf for the arguments passed in' do
          subject.set_exitcode(1, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
    end
  end
  context '#add_output' do
    context 'with any setup' do
      context 'regardless of existing or non-existing configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              exitcode: 0,
              outputs: [
                {
                  target: :stderr,
                  type: :stderr,
                  content: '2'
                }
              ]
            }
          ]
        end
        it 'updates the internal configuration but converts output to a string' do
          subject.add_output(2, :stderr, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
      context 'with no existing configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              exitcode: 0,
              outputs: [
                {
                  target: :stderr,
                  type: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
        it 'updates the outputs for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
      context 'with an existing, non-matching configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument),
              exitcode: 1,
              outputs: [
                {
                  target: :stdout,
                  type: :stdout,
                  content: 'different_content'
                }
              ]
            },
            {
              args: %w(first_argument second_argument),
              exitcode: 0,
              outputs: [
                {
                  target: :stderr,
                  type: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument),
              exitcode: 1,
              outputs: [
                {
                  target: :stdout,
                  type: :stdout,
                  content: 'different_content'
                }
              ]
            }
          ]
        end
        it 'updates the outputs conf for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
      context 'with an existing, matching configuration' do
        let(:expected_conf) do
          [
            {
              args: %w(first_argument second_argument),
              exitcode: 1,
              outputs: [
                {
                  target: :stdout,
                  type: :stdout,
                  content: 'old_content'
                },
                {
                  target: :stderr,
                  type: :stderr,
                  content: 'new_content'
                }
              ]
            }
          ]
        end
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument second_argument),
              exitcode: 1,
              outputs: [
                {
                  target: :stdout,
                  type: :stdout,
                  content: 'old_content'
                }
              ]
            }
          ]
        end
        it 'adds to the outputs conf for the arguments passed in' do
          subject.add_output('new_content', :stderr, %w(first_argument second_argument))
          expect(subject.call_configuration).to eql expected_conf
        end
      end
    end
  end
  context '#get_best_call_conf' do
    context 'with any setup' do
      context 'with no existing configuration' do
        it 'updates the status code conf for the arguments passed in' do
          call_conf = subject.get_best_call_conf(%w(first_argument second_argument))
          expect(call_conf).to eql({})
        end
      end
      context 'with an existing, non-matching configuration' do
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument),
              exitcode: 1,
              outputs: []
            }
          ]
        end
        it 'returns an empty hash indicating no match was found' do
          call_conf = subject.get_best_call_conf(%w(first_argument second_argument))
          expect(call_conf).to eql({})
        end
      end
      context 'with an existing, matching configuration' do
        let(:expected_conf) do
          {
            exitcode: 2,
            outputs: [
              target: 'first_argument-something-second_argument-another.txt',
              type: :file,
              content: 'dynamically generated file name contents'
            ]
          }
        end
        before do
          subject.call_configuration = [
            {
              args: %w(first_argument second_argument),
              exitcode: 2,
              outputs: [
                target: [
                  :arg1,
                  '-something-',
                  :arg2,
                  '-another.txt'
                ],
                type: :file,
                content: 'dynamically generated file name contents'
              ]
            }
          ]
        end

        it 'returns the matching hash with args removed and paths adjusted' do
          call_conf = subject.get_best_call_conf(%w(first_argument second_argument))
          expect(call_conf).to eql expected_conf
        end
      end
    end
  end
end
