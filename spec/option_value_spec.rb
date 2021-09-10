require 'spec_helper'
require 'command_mapper/option_value'

describe CommandMapper::OptionValue do
  describe "#initialize" do
    it "must default #required? to true" do
      expect(subject.required?).to be(true)
    end

    it "must default #allow_empty? to false" do
      expect(subject.allow_empty?).to be(false)
    end

    context "when initialized with required: false" do
      subject { described_class.new(required: false) }

      it "#required? must return false" do
        expect(subject.required?).to be(false)
      end
    end

    context "when initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      it "#allow_empty? must return true" do
        expect(subject.allow_empty?).to be(true)
      end
    end
  end

  describe "#allow_empty?" do
    context "when initialized with allow_empty: true" do
      subject { described_class.new(allow_empty: true) }

      it "#allow_empty? must be true" do
        expect(subject.allow_empty?).to be(true)
      end
    end

    context "when initialized with allow_empty: false" do
      subject { described_class.new(allow_empty: false) }

      it "#allow_empty? must be false" do
        expect(subject.allow_empty?).to be(false)
      end
    end
  end
end
