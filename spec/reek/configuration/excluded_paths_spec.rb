require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/excluded_paths'

RSpec.describe Reek::Configuration::ExcludedPaths do
  describe '#add' do
    subject { [].extend(described_class) }

    context 'one of given paths does not exist' do
      let(:bogus_path) { Pathname('does/not/exist') }
      let(:paths) { [SAMPLES_PATH, bogus_path] }
      let(:path_does_not_exist_message) do
        "Configuration error: Directory `#{bogus_path}` does not exist"
      end

      it 'raises an error' do
        expect { subject.add(paths) }.to raise_error(SystemExit,
                                                     path_does_not_exist_message)
      end
    end

    context 'one of given paths is a file' do
      let(:file_as_path) { SAMPLES_PATH.join('inline.rb') }
      let(:paths) { [SAMPLES_PATH, file_as_path] }
      let(:path_is_file_message) do
        "Configuration error: `#{file_as_path}` is supposed to be a directory but is a file"
      end

      it 'raises an error if one of given paths is a file' do
        expect { subject.add(paths) }.to raise_error(SystemExit,
                                                     path_is_file_message)
      end
    end
  end
end
