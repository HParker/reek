require 'pathname'
require_relative '../../spec_helper'
require_relative '../../../lib/reek/configuration/directory_directives'

RSpec.describe Reek::Configuration::DefaultDirective do
  describe '#add_smell_configuration' do
    subject { {}.extend(described_class) }

    it 'adds a smell configuration' do
      subject.add_smell_configuration :UncommunicativeVariableName, enabled: false
      expect(subject).to eq(Reek::Smells::UncommunicativeVariableName => { enabled: false })
    end
  end
end
