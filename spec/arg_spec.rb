require 'spec_helper'
require 'command_mapper/arg'
require 'command_mapper/types/list'

describe CommandMapper::Arg do
  describe "#initialize" do
    it "must default #type to a Types::Str object" do
      expect(subject.type).to be_kind_of(Types::Str)
    end

    context "when given the type: keyword argument" do
      context "and it's a Types::Type object" do
        let(:type) { Types::List.new(separator: ',') }

        subject { described_class.new(type: type) }

        it "must set #type" do
          expect(subject.type).to eq(type)
        end
      end

      context "but it's nil" do
        it do
          expect {
            described_class.new(type: nil)
          }.to raise_error(ArgumentError,"type: keyword cannot be nil")
        end
      end
    end

    context "when given the required: true keyword argument" do
      subject { described_class.new(required: true) }

      it "type's #required? must be true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when given the required: false keyword argument" do
      subject { described_class.new(required: false) }

      it "the #type's #required? must be false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  let(:required) { true }
  let(:type)     { Types::Str.new }

  subject do
    described_class.new(
      required: required,
      type:     type
    )
  end

  describe "#required?" do
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
    context "when the argument requires a value" do
      let(:required) { true }

      context "is given a String" do
        let(:value) { "foo" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "and is given nil" do
        let(:value) { nil }

        it "must return true" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow a nil value"]
          )
        end
      end
    end

    context "when the argument does not require a value" do
      let(:required) { false }

      context "is given a String" do
        let(:value) { "foo" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "and is given nil" do
        let(:value) { nil }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end
    end
  end
end
