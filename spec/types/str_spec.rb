require 'spec_helper'
require 'command_mapper/types/str'

describe CommandMapper::Types::Str do
  describe "#initialize" do
    it "must default allow_empty: to false" do
      expect(subject.allow_empty?).to be(false)
    end

    it "must default allow_blank: to false" do
      expect(subject.allow_blank?).to be(false)
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
end
