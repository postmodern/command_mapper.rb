require 'spec_helper'
require 'command_mapper/argument_value'
require 'command_mapper/formats/list'

describe CommandMapper::ArgumentValue do
  include CommandMapper

  let(:format) { Formats::List.new(',') }

  describe "#initialize" do
    context "when given the format: keyword argument" do
      subject { described_class.new(format: format) }

      it "must set #format" do
        expect(subject.format).to eq(format)
      end
    end

    context "when given the required: true keyword argument" do
      subject { described_class.new(required: true) }

      it "#required? must be true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when given the required: false keyword argument" do
      subject { described_class.new(required: false) }

      it "#required? must be false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  describe "#required?" do
    context "when initialized with required: true" do
      subject { described_class.new(required: true) }

      it "#required? must be true" do
        expect(subject.required?).to be(true)
      end
    end

    context "when initialized with required: false" do
      subject { described_class.new(required: false) }

      it "#required? must be false" do
        expect(subject.required?).to be(false)
      end
    end
  end

  describe "#optional?" do
    context "when initialized with required: true" do
      subject { described_class.new(required: true) }

      it "#optional? must be false" do
        expect(subject.required?).to be(true)
      end
    end

    context "when initialized with required: false" do
      subject { described_class.new(required: false) }

      it "#optional? must be true" do
        expect(subject.optional?).to be(true)
      end
    end
  end

  describe "#format_value" do
    context "when #format is set" do
      subject { described_class.new(format: format) }

      let(:value) { %w[one two three] }

      it "must pass call #call on the #format object" do
        expect(subject.format_value(value)).to eq(format.call(value))
      end
    end
  end
end
