require 'spec_helper'
include Rspec::Bash::Util

describe 'CallConfArgumentListMatcher' do
  context '#get_best_call_conf' do
    context 'given a call conf list with a with multiple sets of args, output and exitcodes' do
      let(:call_conf_list) do
        [
          {
            args: [],
            exitcode: 6,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'seventh_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument third_argument),
            exitcode: 1,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'second_content'
              }
            }
          },
          {
            args: ['first_argument', anything, anything],
            exitcode: 3,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fourth_content'
              }
            }
          },
          {
            args: [anything, 'second_argument'],
            exitcode: 4,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fifth_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 0,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'first_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 2,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'third_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything],
            exitcode: 5,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'sixth_content'
              }
            }
          },
          {
            args: [anything, anything, 'third_argument', anything, anything],
            exitcode: 7,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'eighth_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything, anything],
            exitcode: 8,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'ninth_content'
              }
            }
          },
          {
            args: [anything],
            exitcode: 9,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'tenth_content'
              }
            }
          },
          {
            args: [anything],
            exitcode: 10,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'eleventh_content'
              }
            }
          }
        ]
      end

      it 'returns the longest conf match' do
        argument_list_from_call = %w(first_argument second_argument third_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to eql call_conf_list.at(2)
      end

      it 'returns the last longest conf match for multiple exact matches' do
        argument_list_from_call = %w(first_argument second_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to eql call_conf_list.at(5)
      end

      it 'returns the longest conf match for any_arg v. anything matches' do
        argument_list_from_call = %w(first_argument second_argument third_argument fourth_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to eql call_conf_list.at(6)
      end

      it 'returns the last longest conf match for matches with some anythings' do
        argument_list_from_call = %w(
          first_argument second_argument third_argument
          fourth_argument fifth_argument
        )
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to eql call_conf_list.at(8)
      end

      it 'returns the last anything match for multiple, all anything matches' do
        argument_list_from_call = %w(first_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to eql call_conf_list.at(10)
      end
    end
    context 'given a call conf list with a with no all matchers' do
      let(:call_conf_list) do
        [
          {
            args: %w(first_argument second_argument),
            exitcode: 0,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'first_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument third_argument),
            exitcode: 1,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'second_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 2,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'third_content'
              }
            }
          },
          {
            args: ['first_argument', anything, 'third_argument'],
            exitcode: 3,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fourth_content'
              }
            }
          },
          {
            args: [anything, 'second_argument'],
            exitcode: 4,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fifth_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything],
            exitcode: 5,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'sixth_content'
              }
            }
          }
        ]
      end

      it 'returns an empty conf for no matches' do
        argument_list_from_call =
          %w(first_argument second_argument third_argument fourth_argument fifth_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match         = subject.get_best_call_conf(argument_list_from_call)
        expect(call_conf_match).to be_empty
      end
    end
  end
  context '#get_call_conf_matches' do
    context 'given a call conf list with a with multiple sets of args, output and exitcodes' do
      let(:call_conf_list) do
        [
          {
            args: %w(first_argument second_argument),
            exitcode: 0,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'first_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument third_argument),
            exitcode: 1,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'second_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 2,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'third_content'
              }
            }
          },
          {
            args: ['first_argument', YAML.load(YAML.dump(anything)), 'third_argument'],
            exitcode: 3,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fourth_content'
              }
            }
          },
          {
            args: [anything, 'second_argument'],
            exitcode: 4,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fifth_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything],
            exitcode: 5,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'sixth_content'
              }
            }
          },
          {
            args: [],
            exitcode: 6,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'seventh_content'
              }
            }
          },
          {
            args: [
              'first_argument', 'second_argument',
              'third_argument', 'fourth_argument', any_args
            ],
            exitcode: 6,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'seventh_content'
              }
            }
          },
          {
            args: [
              'first_argument', 'second_argument',
              'third_argument', 'fourth_argument', YAML.load(YAML.dump(any_args))
            ],
            exitcode: 6,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'seventh_content'
              }
            }
          }
        ]
      end

      it 'returns the correct confs for a single exact/anything argument match' do
        argument_list_from_call = %w(first_argument second_argument third_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match_list    = subject.get_call_conf_matches(argument_list_from_call)
        expect(call_conf_match_list).to eql call_conf_list.values_at(1, 3, 6)
      end

      it 'returns the correct confs for multiple exact/anything argument matches' do
        argument_list_from_call = %w(first_argument second_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match_list    = subject.get_call_conf_matches(argument_list_from_call)
        expect(call_conf_match_list).to eql call_conf_list.values_at(0, 2, 4, 6)
      end

      it 'returns the correct confs for the all argument match' do
        argument_list_from_call = %w(first_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        call_conf_match_list    = subject.get_call_conf_matches(argument_list_from_call)
        expect(call_conf_match_list).to eql call_conf_list.values_at(6)
      end

      it 'returns the correct confs for an any_args match' do
        argument_list_from_call = %w(
          first_argument second_argument
          third_argument fourth_argument fifth_argument
        )
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.get_call_conf_matches(argument_list_from_call)
        expect(actual_args_match).to eql call_conf_list.values_at(6, 7, 8)
      end
    end
  end
  context '#args_match?' do
    context 'given a call conf list with a with multiple sets of args, output and exitcodes' do
      let(:call_conf_list) do
        [
          {
            args: %w(first_argument second_argument),
            exitcode: 0,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'first_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument third_argument),
            exitcode: 1,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'second_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 2,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'third_content'
              }
            }
          },
          {
            args: ['first_argument', anything, 'third_argument'],
            exitcode: 3,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fourth_content'
              }
            }
          },
          {
            args: [anything, 'second_argument'],
            exitcode: 4,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fifth_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything],
            exitcode: 5,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'sixth_content'
              }
            }
          },
          {
            args: [],
            exitcode: 7,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'eighth_content'
              }
            }
          }
        ]
      end

      it 'returns the correct confs for a single exact/anything argument match' do
        argument_list_from_call = %w(first_argument second_argument third_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end

      it 'returns the correct confs for multiple exact/anything argument matches' do
        argument_list_from_call = %w(first_argument second_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end

      it 'returns the correct confs for the all argument match' do
        argument_list_from_call = %w(first_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end
    end
    context 'given a call conf list with a with no all matchers' do
      let(:call_conf_list) do
        [
          {
            args: %w(first_argument second_argument),
            exitcode: 0,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'first_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument third_argument),
            exitcode: 1,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'second_content'
              }
            }
          },
          {
            args: %w(first_argument second_argument),
            exitcode: 2,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'third_content'
              }
            }
          },
          {
            args: ['first_argument', anything, 'third_argument'],
            exitcode: 3,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fourth_content'
              }
            }
          },
          {
            args: [anything, 'second_argument'],
            exitcode: 4,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'fifth_content'
              }
            }
          },
          {
            args: [anything, anything, anything, anything],
            exitcode: 5,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'sixth_content'
              }
            }
          },
          {
            args: [
              'first_argument', 'second_argument',
              'third_argument', 'fourth_argument', any_args
            ],
            exitcode: 6,
            outputs: {
              stdout: {
                target: :stdout,
                content: 'seventh_content'
              }
            }
          }
        ]
      end

      it 'returns the correct confs for a single exact/anything argument match' do
        argument_list_from_call = %w(first_argument second_argument third_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end

      it 'returns the correct confs for multiple exact/anything argument matches' do
        argument_list_from_call = %w(first_argument second_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end

      it 'returns the correct confs for the all argument match' do
        argument_list_from_call = %w(first_argument)
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be false
      end

      it 'returns the correct confs for an any_args match' do
        argument_list_from_call = %w(
          first_argument second_argument
          third_argument fourth_argument fifth_argument
        )
        subject                 = CallConfArgumentListMatcher.new(call_conf_list)
        actual_args_match       = subject.args_match?(argument_list_from_call)
        expect(actual_args_match).to be true
      end
    end
  end
end
