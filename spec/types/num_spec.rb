require 'spec_helper'
require 'command_mapper/types/num'

describe CommandMapper::Types::Num do
  describe "#validate" do
    context "when given an Integer" do
      let(:value) { 1 }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a String" do
      context "and it contains only digits" do
        let(:value) { "0123456789" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "and the String contains a newline" do
          let(:value) { "01234\n56789" }

          it "must return [false, \"contains non-numeric characters (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "contains non-numeric characters (#{value.inspect})"]
            )
          end
        end
      end

      context "and it contains non-digits" do
        let(:value) { "12abc34" }

        it "must return [false, \"contains non-numeric characters (...)\"]" do
          expect(subject.validate(value)).to eq(
            [false, "contains non-numeric characters (#{value.inspect})"]
          )
        end
      end
    end

    context "when given another type of Object" do
      context "but it defines a #to_i method" do
        let(:value) { 1.0 }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "but it does not define a #to_i method" do
        let(:value) { Object.new }

        it "must return [false, \"value cannot be converted into an Integer\"]" do
          expect(subject.validate(value)).to eq(
            [false, "cannot be converted into an Integer (#{value.inspect})"]
          )
        end
      end
    end
  end

  describe "#format" do
    context "when given a String" do
      let(:value) { "1234567890" }

      it "must return the same String" do
        expect(subject.format(value)).to eq(value)
      end
    end

    context "when given an Intger" do
      let(:value) { 1234567890 }

      it "must convert the Integer into a String" do
        expect(subject.format(value)).to eq(value.to_s)
      end
    end

    context "when given another type of Object" do
      let(:value) { 1.0 }

      it "must call #to_i then #to_s" do
        expect(subject.format(value)).to eq(value.to_i.to_s)
      end
    end
  end
end
