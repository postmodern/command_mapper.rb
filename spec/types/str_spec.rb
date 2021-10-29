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
    context "when given nil" do
      let(:value) { nil }

      it "must return [false, \"value cannot be nil\"]" do
        expect(subject.validate(value)).to eq(
          [false, "value cannot be nil"]
        )
      end

      context "but #allow_empty? is true" do
        subject { described_class.new(allow_empty: true) }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end
    end

    context "when a String is given" do
      let(:value) { "foo" }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end

      context "and it's empty" do
        let(:value) { "" }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq([false, "does not allow an empty value"])
        end

        context "but #allow_empty? is true" do
          subject { described_class.new(allow_empty: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "and it's blank" do
        let(:value) { " \t\n\r\v " }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq([false, "does not allow a blank value"])
        end

        context "but #allow_blank? is true" do
          subject { described_class.new(allow_blank: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end
    end

    context "when a Symbol is given" do
      let(:value) { :foo }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end

      context "and it's empty" do
        let(:value) { :"" }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq([false, "does not allow an empty value"])
        end

        context "but #allow_empty? is true" do
          subject { described_class.new(allow_empty: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "and it's blank" do
        let(:value) { :" \t\n\r\v " }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq([false, "does not allow a blank value"])
        end

        context "but #allow_blank? is true" do
          subject { described_class.new(allow_blank: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end
    end

    context "when another kind of Object is given" do
      let(:value) { Object.new }

      it "must return [false, \"value is not a String\"]" do
        expect(subject.validate(value)).to eq(
          [false, "value is not a String"]
        )
      end
    end
  end
end
