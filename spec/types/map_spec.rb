require 'spec_helper'
require 'command_mapper/types/map'

describe CommandMapper::Types::Map do
  let(:map) { {1 => 'one', 2 => 'two'} }

  subject { described_class.new(map) }

  describe "#initialize" do
    it "must initialize #map" do
      expect(subject.map).to eq(map)
    end
  end

  describe ".[]" do
    subject { described_class[map] }

    it "must create a new Map with the given values" do
      expect(subject).to be_kind_of(described_class)
      expect(subject.map).to eq(map)
    end
  end

  describe "#validate" do
    context "when given a value that's a key in the map" do
      let(:value) { 2 }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a value that's a value in the map" do
      let(:value) { "two" }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a value that is not in the map" do
      let(:value) { 42 }

      it "must return [false, \"unknown value (...) must be ..., or ...\"]" do
        expect(subject.validate(value)).to eq(
          [false, "unknown value (#{value.inspect}) must be #{subject.map.keys.map(&:inspect).join(', ')}, or #{subject.map.values.map(&:inspect).join(', ')}"]
        )
      end
    end
  end

  describe "#format" do
    context "when given a value that's a key in the map" do
      let(:value) { 2 }

      it "must return the corresponding mapped value" do
        expect(subject.format(value)).to eq(map[value])
      end
    end

    context "when given a value that's a value in the map" do
      let(:value) { "two" }

      it "must return the value" do
        expect(subject.format(value)).to eq(value)
      end
    end

    context "when given a value that is not in the map" do
      let(:value) { 42 }

      it "must return the String version of the value" do
        expect {
          subject.format(value)
        }.to raise_error(KeyError,"value (#{value.inspect}) is not a key or value in the map: #{map.inspect}")
      end
    end
  end
end
