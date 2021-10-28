require 'spec_helper'
require 'command_mapper/types/type'

describe CommandMapper::Types::Type do
  describe "#initialize" do
    it "must default required: to true" do
      expect(subject.required?).to be(true)
    end

    context "when given required: true" do
      subject { described_class.new(required: true) }

      it "must set required: to true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when given required: false" do
      subject { described_class.new(required: false) }

      it "must set required: to false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  describe "#required?" do
    it "must be true by default" do
      expect(subject.required?).to be(true)
    end

    context "when initialized with required: true" do
      subject { described_class.new(required: true) }

      it "must be true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when initialized with required: true" do
      subject { described_class.new(required: false) }

      it "must be false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  describe "#optional?" do
    it "must be true by default" do
      expect(subject.optional?).to be(false)
    end

    context "when initialized with required: false" do
      subject { described_class.new(required: false) }

      it "must be true" do
        expect(subject.optional?).to be(true)
      end
    end

    context "when initialized with required: true" do
      subject { described_class.new(required: true) }

      it "must be false" do
        expect(subject.optional?).to be(false)
      end
    end
  end

  describe "#validate" do
    subject { described_class.new(required: true) }

    context "and a nil value is given" do
      it "must return false and a validation error message" do
        expect(subject.validate(nil)).to eq([false, "does not allow a nil value"])
      end
    end

    context "and a non-nil value is given" do
      it "must return true" do
        expect(subject.validate("foo")).to be(true)
      end
    end

    context "when initialized with required: false" do
      subject { described_class.new(required: false) }

      context "and a nil is given" do
        it "must return nil" do
          expect(subject.validate(nil)).to be(true)
        end
      end

      context "and a non-nil value is given" do
        it "must return true" do
          expect(subject.validate("foo")).to be(true)
        end
      end
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
    let(:value) { {required: true} }

    subject { CommandMapper::Types::Type(value) }

    it "must initialize a new CommandMapper::Types::Str" do
      expect(subject).to be_kind_of(CommandMapper::Types::Str)
      expect(subject.required?).to be(true)
    end
  end

  context "when given :required" do
    let(:value) { :required }

    subject { CommandMapper::Types::Type(value) }

    it "must initialize a new CommandMapper::Types::Str" do
      expect(subject).to be_kind_of(CommandMapper::Types::Str)
    end

    it "must set initialize the new value with required: true" do
      expect(subject.required?).to be(true)
    end
  end

  context "when given :optional" do
    let(:value) { :optional }

    subject { CommandMapper::Types::Type(value) }

    it "must initialize a new CommandMapper::Types::Str" do
      expect(subject).to be_kind_of(CommandMapper::Types::Str)
    end

    it "must set initialize the new value with required: false" do
      expect(subject.required?).to be(false)
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
      }.to raise_error(ArgumentError,"value must be a CommandMapper::Types::Type, Hash, :required, :optional, or nil: #{value.inspect}")
    end
  end
end
