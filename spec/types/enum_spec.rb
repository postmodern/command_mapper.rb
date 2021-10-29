require 'spec_helper'
require 'command_mapper/types/enum'

describe CommandMapper::Types::Enum do
  let(:values) { [:foo, 42, :bar] }

  subject { described_class.new(values) }

  describe "#initialize" do
    it "must set #values" do
      expect(subject.values).to eq(values)
    end

    it "must populate #map with the values and their String forms" do
      expect(subject.map).to eq(
        Hash[values.map { |value|
          [value, value.to_s]
        }]
      )
    end
  end

  describe ".[]" do
    subject { described_class[*values] }

    it "must create a new Enum with the given values" do
      expect(subject).to be_kind_of(described_class)
      expect(subject.values).to eq(values)
    end
  end
end
