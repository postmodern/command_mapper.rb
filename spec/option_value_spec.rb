require 'spec_helper'
require 'command_mapper/option_value'
require 'command_mapper/types/list'

describe CommandMapper::OptionValue do
  describe "#format" do
    let(:type) { Types::List.new }

    subject { described_class.new(type: type) }

    let(:value) { [1,2,3] }

    it "must call the #type.format" do
      expect(subject.format(value)).to eq(type.format(value))
    end
  end
end
