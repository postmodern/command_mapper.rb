require 'spec_helper'
require 'command_mapper/types/hex'

describe CommandMapper::Types::Hex do
  describe "#initialize" do
    it "must default #leading_zero? to false" do
      expect(subject.leading_zero?).to be(false)
    end

    context "when initialized with leading_zero: true" do
      subject { described_class.new(leading_zero: true) }

      it "must set #leading_zero? to true" do
        expect(subject.leading_zero?).to be(true)
      end
    end
  end

  describe "#leading_zero?" do
    context "when initialized with leading_zero: true" do
      subject { described_class.new(leading_zero: true) }

      it "must return true" do
        expect(subject.leading_zero?).to be(true)
      end
    end

    context "when initialized with leading_zero: false" do
      subject { described_class.new(leading_zero: false) }

      it "must return false" do
        expect(subject.leading_zero?).to be(false)
      end
    end
  end

  describe "#format" do
    context "when given an Integer" do
      let(:value) { 255 }

      it "must return the hexadecimal form of the Integer" do
        expect(subject.format(value)).to eq("ff")
      end

      context "when initialized with leading_zero: true" do
        subject { described_class.new(leading_zero: true) }

        it "must prepend the hexadecimal number with '0x'" do
          expect(subject.format(value)).to eq("0xff")
        end
      end
    end

    context "when given a String" do
      context "and it contains only digits" do
        let(:value) { "255" }

        it "must return the hexadecimal number form of the String" do
          expect(subject.format(value)).to eq("ff")
        end

        context "when initialized with leading_zero: true" do
          subject { described_class.new(leading_zero: true) }

          it "must prepend the hexadecimal number with '0x'" do
            expect(subject.format(value)).to eq("0xff")
          end
        end
      end
    end
  end
end
