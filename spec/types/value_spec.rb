require 'spec_helper'
require 'command_mapper/types/value'

describe CommandMapper::Types::Value do
  describe "#initialize" do
    it "must default required: to true" do
      expect(subject.required?).to be(true)
    end

    it "must default allow_empty: to false" do
      expect(subject.allow_empty?).to be(false)
    end

    it "must default allow_blank: to false" do
      expect(subject.allow_blank?).to be(false)
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

    context "when given allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      it "must set allow_empty: to true" do
        expect(subject.allow_empty?).to be(true)
      end
    end

    context "when given allow_empty: false" do
      subject { described_class.new(allow_empty: false) }

      it "must set allow_empty: to false" do
        expect(subject.allow_empty?).to be(false)
      end
    end

    context "when given allow_blank: true" do
      subject { described_class.new(allow_blank: true) }

      it "must set allow_blank: to true" do
        expect(subject.allow_blank?).to be(true)
      end
    end

    context "when given allow_blank: false" do
      subject { described_class.new(allow_blank: false) }

      it "must set allow_blank: to false" do
        expect(subject.allow_blank?).to be(false)
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

  describe "#allow_empty?" do
    it "must be false by default" do
      expect(subject.allow_empty?).to be(false)
    end

    context "when initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      it "must be true" do
        expect(subject.allow_empty?).to be(true)
      end
    end

    context "when initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: false) }

      it "must be false" do
        expect(subject.allow_empty?).to be(false)
      end
    end
  end

  describe "#allow_blank?" do
    it "must be false by default" do
      expect(subject.allow_blank?).to be(false)
    end

    context "when initialized with allow_blank: true" do
      subject { described_class.new(allow_blank: true) }

      it "must be true" do
        expect(subject.allow_blank?).to be(true)
      end
    end

    context "when initialized with allow_blank: true" do
      subject { described_class.new(allow_blank: false) }

      it "must be false" do
        expect(subject.allow_blank?).to be(false)
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

    context "and an empty String is given" do
      it "must return false and a validation error message" do
        expect(subject.validate("")).to eq([false, "does not allow an empty value"])
      end
    end

    context "and a blank String is given" do
      it "must return false and a validation error message" do
        expect(subject.validate("  ")).to eq([false, "does not allow a blank value"])
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

    context "but it's also initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      context "and a blank String is given" do
        it "must return true" do
          expect(subject.validate("")).to be(true)
        end
      end
    end

    context "but it's also initialized with allow_blank: true" do
      subject { described_class.new(allow_blank: true) }

      context "and a blank String is given" do
        it "must return true" do
          expect(subject.validate("  ")).to be(true)
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

describe "CommandMapper::Types::Value()" do
  context "when given a CommandMapper::Types::Value" do
    let(:value) { CommandMapper::Types::Value.new }

    subject { CommandMapper::Types::Value(value) }

    it "must return the value" do
      expect(subject).to be(value)
    end
  end

  context "when given a Hash" do
    let(:value) { {required: true, allow_empty: true} }

    subject { CommandMapper::Types::Value(value) }

    it "must initialize a new CommandMapper::Types::Value" do
      expect(subject).to be_kind_of(CommandMapper::Types::Value)
      expect(subject.required?).to be(true)
      expect(subject.allow_empty?).to be(true)
    end
  end

  context "when given true" do
    let(:value) { true }

    subject { CommandMapper::Types::Value(value) }

    it "must initialize a new CommandMapper::Types::Value" do
      expect(subject).to be_kind_of(CommandMapper::Types::Value)
    end

    it "must set initialize the new value with required: true" do
      expect(subject.required?).to be(true)
    end
  end

  context "when given false" do
    let(:value) { false }

    subject { CommandMapper::Types::Value(value) }

    it "must initialize a new CommandMapper::Types::Value" do
      expect(subject).to be_kind_of(CommandMapper::Types::Value)
    end

    it "must set initialize the new value with required: false" do
      expect(subject.required?).to be(false)
    end
  end

  context "when given nil" do
    let(:value) { nil }

    subject { CommandMapper::Types::Value(value) }

    it "must return nil" do
      expect(subject).to be(nil)
    end
  end

  context "when given another kind of Object" do
    let(:value) { Object.new }

    it do
      expect {
        CommandMapper::Types::Value(value)
      }.to raise_error(ArgumentError,"value must be a CommandMapper::Types::Value, Hash, true, false, or nil: #{value.inspect}")
    end
  end
end
