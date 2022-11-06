require 'spec_helper'
require 'command_mapper/types/dec'

describe CommandMapper::Types::Dec do
  describe "#initialize" do
    context "when initialized with no keyword arguments" do
      it "must set #range to nil" do
        expect(subject.range).to be(nil)
      end
    end

    context "when initialized with range: ..." do
      let(:range) { 1.0..1.5 }

      subject { described_class.new(range: range) }

      it "must set #range" do
        expect(subject.range).to eq(range)
      end
    end
  end

  describe "#validate" do
    context "when given an Integer" do
      let(:value) { 1 }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end

      context "when initialized with range: ..." do
        let(:range) { 2.0..10.0 }

        subject { described_class.new(range: range) }

        context "and the value is within the range of values" do
          let(:value) { 4.0 }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the value is not within the range of values" do
          let(:value) { 0.0 }

          it "must return [false, \"(...) not within the range of acceptable values (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (#{range.inspect})"]
            )
          end
        end
      end
    end

    context "when given a String" do
      context "and it contains only digits" do
        let(:value) { "0123456789" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "when initialized with range: ..." do
          let(:range) { 2.0..10.0 }

          subject { described_class.new(range: range) }

          context "and the value is within the range of values" do
            let(:value) { '4.0' }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end

          context "but the value is not within the range of values" do
            let(:value) { '0.0' }

            it "must return [false, \"(...) not within the range of acceptable values (...)\"]" do
              expect(subject.validate(value)).to eq(
                [false, "(#{value.inspect}) not within the range of acceptable values (#{range.inspect})"]
              )
            end
          end
        end

        context "but the String contains a newline" do
          let(:value) { "01234.\n56789" }

          it "must return [false, \"contains non-decimal characters (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "contains non-decimal characters (#{value.inspect})"]
            )
          end
        end
      end

      context "but it contains non-digits" do
        let(:value) { "12.abc34" }

        it "must return [false, \"contains non-decimal characters (...)\"]" do
          expect(subject.validate(value)).to eq(
            [false, "contains non-decimal characters (#{value.inspect})"]
          )
        end
      end
    end

    context "when given another type of Object" do
      context "and it defines a #to_f method" do
        let(:value) { 1 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "when initialized with range: ..." do
        let(:range) { 2.0..10.0 }

        subject { described_class.new(range: range) }

        context "and the value is within the range of values" do
          let(:value) { 4 }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "but the value is not within the range of values" do
          let(:value) { 0 }

          it "must return [false, \"(...) not within the range of acceptable values (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "(#{value.inspect}) not within the range of acceptable values (#{range.inspect})"]
            )
          end
        end
      end

      context "but it does not define a #to_f method" do
        let(:value) { Object.new }

        it "must return [false, \"value cannot be converted into a Float\"]" do
          expect(subject.validate(value)).to eq(
            [false, "cannot be converted into a Float (#{value.inspect})"]
          )
        end
      end
    end
  end

  describe "#format" do
    context "when given a String" do
      let(:value) { "12345.67890" }

      it "must return the same String" do
        expect(subject.format(value)).to eq(value)
      end
    end

    context "when given an Intger" do
      let(:value) { 12345.67890 }

      it "must convert the Integer into a String" do
        expect(subject.format(value)).to eq(value.to_s)
      end
    end

    context "when given another type of Object" do
      let(:value) { 1 }

      it "must call #to_i then #to_s" do
        expect(subject.format(value)).to eq(value.to_f.to_s)
      end
    end
  end
end
