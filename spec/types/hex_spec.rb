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

  describe "#validate" do
    context "when given a String" do
      context "and the String only contains decimal digits" do
        let(:value) { "0123456789" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "and the String begins with a '0x'" do
          let(:value) { "0x0123456789" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and the String contains a newline" do
          let(:value) { "01234\n56789" }

          it "must return [false, \"not in hex format (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "not in hex format (#{value.inspect})"]
            )
          end
        end
      end

      context "and the String only contains hex digits" do
        let(:value) { "abcdef" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "and the String begins with a '0x'" do
          let(:value) { "0xabcdef" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and the String contains a newline" do
          let(:value) { "abc\ndef" }

          it "must return [false, \"not in hex format (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "not in hex format (#{value.inspect})"]
            )
          end
        end
      end

      context "but the String does not contain other characters" do
        let(:value) { "foo" }

        it "must return [false, \"not in hex format (...)\"]" do
          expect(subject.validate(value)).to eq(
            [false, "not in hex format (#{value.inspect})"]
          )
        end

        context "and the String contains a newline" do
          let(:value) { "foo\nbar" }

          it "must return [false, \"not in hex format (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "not in hex format (#{value.inspect})"]
            )
          end
        end
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
      context "and it contains hexadecimal digits" do
        let(:value) { "ff" }

        it "must return the String" do
          expect(subject.format(value)).to eq("ff")
        end

        context "but the String does start with '0x'" do
          let(:value) { "0xff" }

          it "must remove '0x' prefix" do
            expect(subject.format(value)).to eq("ff")
          end
        end

        context "when #leading_zero? is true" do
          subject { described_class.new(leading_zero: true) }

          context "but the String does not start with '0x'" do
            it "must prepend the String with '0x'" do
              expect(subject.format(value)).to eq("0xff")
            end
          end
        end
      end
    end
  end
end
