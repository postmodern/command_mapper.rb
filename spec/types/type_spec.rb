require 'spec_helper'
require 'command_mapper/types/type'

describe CommandMapper::Types::Type do
  describe "#validate" do
    it "must return true by default" do
      expect(subject.validate(Object.new)).to be(true)
    end
  end

  describe "#format" do
    it "must convert the given value into a String" do
      expect(subject.format(1)).to eq("1")
    end
  end
end

describe "CommandMapper::Types::Type()" do
  context "when given a CommandMapper::Types::Type" do
    let(:value) { CommandMapper::Types::Type.new }

    subject { CommandMapper::Types::Type(value) }

    it "must return the CommandMapper::Types::Type object" do
      expect(subject).to be(value)
    end
  end

  context "when given a Hash" do
    let(:value) { {allow_empty: true} }

    subject { CommandMapper::Types::Type(value) }

    it "must initialize a new CommandMapper::Types::Str" do
      expect(subject).to be_kind_of(CommandMapper::Types::Str)
      expect(subject.allow_empty?).to be(true)
    end
  end

  context "when given nil" do
    let(:value) { nil }

    subject { CommandMapper::Types::Type(value) }

    it "must return nil" do
      expect(subject).to be(nil)
    end
  end

  context "when given another kind of Object" do
    let(:value) { Object.new }

    it do
      expect {
        CommandMapper::Types::Type(value)
      }.to raise_error(ArgumentError,"value must be a CommandMapper::Types::Type, Hash, or nil: #{value.inspect}")
    end
  end
end
